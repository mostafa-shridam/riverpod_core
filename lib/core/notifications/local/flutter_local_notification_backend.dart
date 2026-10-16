import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_core/core/notifications/channels/notification_categories.dart';
import 'package:riverpod_core/core/notifications/channels/notification_channels.dart';
import 'package:riverpod_core/core/notifications/local/local_notification_backend.dart';
import 'package:riverpod_core/core/notifications/local/local_notification_mapper.dart';
import 'package:riverpod_core/core/notifications/models/app_notification_channel.dart';
import 'package:riverpod_core/core/notifications/models/app_notification_channel_group.dart';
import 'package:riverpod_core/core/notifications/models/local_notification.dart';
import 'package:riverpod_core/core/notifications/models/notification_payload.dart';
import 'package:riverpod_core/core/notifications/models/notification_tap.dart';
import 'package:riverpod_core/core/notifications/models/notification_tap_source.dart';
import 'package:riverpod_core/core/notifications/models/pending_notification.dart';
import 'package:riverpod_core/core/notifications/models/schedule_repeat.dart';
import 'package:riverpod_core/core/notifications/models/scheduled_notification.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// [LocalNotificationBackend] over `flutter_local_notifications`.
///
/// Permissions are NOT requested here (the permission flow owns that), so
/// initialising never shows a system prompt.
class FlutterLocalNotificationBackend implements LocalNotificationBackend {
  FlutterLocalNotificationBackend({
    FlutterLocalNotificationsPlugin? plugin,
    this.androidIcon = 'ic_notification',
    this.accentColor,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  /// Drawable of the monochrome status-bar icon.
  final String androidIcon;

  /// Accent color of Android notifications (from the design tokens).
  final Color? accentColor;

  /// Reserved id of the silent notification that only sets the iOS badge.
  static const _badgeNotificationId = 0x7fffff00;

  NotificationLabelResolver _label = (key) => key;
  NotificationTapCallback? _onTap;

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;
  bool get _isIos => defaultTargetPlatform == TargetPlatform.iOS;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> initialize({
    required String timezoneName,
    required NotificationTapCallback onTap,
  }) async {
    _onTap = onTap;
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } on tz.LocationNotFoundException {
      // Unknown zone name: scheduling falls back to UTC.
    }
    await _plugin.initialize(
      settings: InitializationSettings(
        android: AndroidInitializationSettings(androidIcon),
        iOS: _darwinSettings(),
      ),
      onDidReceiveNotificationResponse: (response) =>
          onTap(_tapOf(response, NotificationTapSource.localTap)),
    );
  }

  DarwinInitializationSettings _darwinSettings() =>
      DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: [
          DarwinNotificationCategory(
            NotificationCategories.message,
            actions: [
              DarwinNotificationAction.text(
                NotificationCategories.replyAction,
                _label(LocaleKeys.notifications_actionReply),
                buttonTitle: _label(LocaleKeys.notifications_actionReplySend),
                placeholder: _label(LocaleKeys.notifications_actionReplyHint),
              ),
              DarwinNotificationAction.plain(
                NotificationCategories.markReadAction,
                _label(LocaleKeys.notifications_actionMarkRead),
              ),
            ],
          ),
        ],
      );

  NotificationTap _tapOf(
    NotificationResponse response,
    NotificationTapSource source,
  ) => NotificationTap(
    payload:
        NotificationPayload.tryParse(response.payload) ??
        const NotificationPayload(),
    source: source,
    actionId: response.actionId,
    input: response.input,
  );

  @override
  Future<void> createChannels({
    required List<AppNotificationChannel> channels,
    required List<AppNotificationChannelGroup> groups,
    required NotificationLabelResolver label,
  }) async {
    _label = label;
    if (_isIos) {
      // Categories carry localized button titles: register them again now that
      // the translations are loaded.
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.initialize(
            settings: _darwinSettings(),
            onDidReceiveNotificationResponse: (response) =>
                _onTap?.call(_tapOf(response, NotificationTapSource.localTap)),
          );
      return;
    }
    final android = _android;
    if (android == null) return;
    for (final group in groups) {
      await android.createNotificationChannelGroup(
        AndroidNotificationChannelGroup(group.id, label(group.nameKey)),
      );
    }
    for (final channel in channels) {
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          channel.id,
          label(channel.nameKey),
          description: label(channel.descriptionKey),
          groupId: channel.groupId,
          importance: LocalNotificationMapper.importance(channel.importance),
          playSound: channel.playSound,
          enableVibration: channel.enableVibration,
          showBadge: channel.showBadge,
        ),
      );
    }
  }

  @override
  Future<NotificationTap?> launchTap() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    final response = details?.notificationResponse;
    if (details == null ||
        !details.didNotificationLaunchApp ||
        response == null) {
      return null;
    }
    return _tapOf(response, NotificationTapSource.localLaunch);
  }

  NotificationDetails _detailsOf(LocalNotification n) {
    final channel = NotificationChannels.byId(n.channelId);
    return LocalNotificationMapper.details(
      n,
      channelImportance: channel.importance,
      channelName: _label(channel.nameKey),
      androidIcon: androidIcon,
      accentColor: accentColor,
    );
  }

  @override
  Future<void> show(LocalNotification notification) => _plugin.show(
    id: notification.id,
    title: notification.title,
    body: notification.body,
    notificationDetails: _detailsOf(notification),
    payload: notification.payload?.toJson(),
  );

  @override
  Future<void> schedule(ScheduledNotification scheduled) {
    final n = scheduled.notification;
    return _plugin.zonedSchedule(
      id: n.id,
      scheduledDate: tz.TZDateTime.from(scheduled.when, tz.local),
      notificationDetails: _detailsOf(n),
      androidScheduleMode: scheduled.exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      title: n.title,
      body: n.body,
      payload: n.payload?.toJson(),
      matchDateTimeComponents: switch (scheduled.repeat) {
        ScheduleRepeat.none => null,
        ScheduleRepeat.daily => DateTimeComponents.time,
        ScheduleRepeat.weekly => DateTimeComponents.dayOfWeekAndTime,
      },
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<List<PendingNotification>> pending() async {
    final requests = await _plugin.pendingNotificationRequests();
    return [
      for (final request in requests)
        PendingNotification(
          id: request.id,
          title: request.title,
          body: request.body,
          payload: request.payload,
        ),
    ];
  }

  @override
  Future<bool> canScheduleExact() async {
    if (!_isAndroid) return true;
    return await _android?.canScheduleExactNotifications() ?? false;
  }

  @override
  Future<bool> requestExactAlarmPermission() async {
    if (!_isAndroid) return true;
    return await _android?.requestExactAlarmsPermission() ?? false;
  }

  @override
  Future<void> setBadge(int count) async {
    if (!_isIos) return;
    await _plugin.show(
      id: _badgeNotificationId,
      notificationDetails: LocalNotificationMapper.badgeOnly(count),
    );
  }
}

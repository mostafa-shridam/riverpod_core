import 'package:riverpod_core/core/logger/app_logger.dart';
import 'package:riverpod_core/core/notifications/channels/notification_channels.dart';
import 'package:riverpod_core/core/notifications/local/local_notification_backend.dart';
import 'package:riverpod_core/core/notifications/models/local_notification.dart';
import 'package:riverpod_core/core/notifications/models/notification_payload.dart';
import 'package:riverpod_core/core/notifications/models/pending_notification.dart';
import 'package:riverpod_core/core/notifications/models/schedule_repeat.dart';
import 'package:riverpod_core/core/notifications/models/schedule_result.dart';
import 'package:riverpod_core/core/notifications/models/scheduled_notification.dart';
import 'package:riverpod_core/core/notifications/settings/notification_settings.dart';

/// Shows, schedules and cancels local notifications, honouring the user's
/// master and per-channel switches.
class LocalNotificationService {
  LocalNotificationService({
    required LocalNotificationBackend backend,
    required NotificationSettings Function() settings,
    required DateTime Function() now,
    required AppLogger logger,
  }) : _backend = backend,
       _settings = settings,
       _now = now,
       _logger = logger;

  final LocalNotificationBackend _backend;
  final NotificationSettings Function() _settings;
  final DateTime Function() _now;
  final AppLogger _logger;

  int _lastId = 0;

  /// A fresh notification id (positive 31-bit, unique per run). Keep your own
  /// ids for notifications you will cancel or replace.
  int nextId() {
    var id = _now().millisecondsSinceEpoch.remainder(0x7fffff00);
    if (id <= _lastId) id = _lastId + 1;
    return _lastId = id;
  }

  /// Shows a notification now. Returns its id, or null when the user turned
  /// the channel (or all notifications) off.
  Future<int?> show({
    required String title,
    required String body,
    String channelId = NotificationChannels.defaultChannelId,
    NotificationPayload? payload,
    int? id,
    String? bigText,
    String? bigPicturePath,
    String? groupKey,
    int? badge,
    String? categoryId,
  }) async {
    final notification = LocalNotification(
      id: id ?? nextId(),
      title: title,
      body: body,
      channelId: channelId,
      payload: payload,
      bigText: bigText,
      bigPicturePath: bigPicturePath,
      groupKey: groupKey,
      badge: badge,
      categoryId: categoryId,
    );
    return await showNotification(notification) ? notification.id : null;
  }

  /// Shows a prepared [notification]. False when it is switched off.
  Future<bool> showNotification(LocalNotification notification) async {
    if (!_settings().isChannelEnabled(notification.channelId)) {
      _logger.debug('Notification skipped: channel switched off');
      return false;
    }
    await _backend.show(notification);
    return true;
  }

  /// Android: the summary row that stacks every notification of [groupKey].
  /// Show it after the children (each child needs the same `groupKey`).
  Future<bool> showGroupSummary({
    required String groupKey,
    required String title,
    required List<String> lines,
    required String summaryText,
    String channelId = NotificationChannels.defaultChannelId,
    int? id,
  }) => showNotification(
    LocalNotification(
      id: id ?? groupKey.hashCode & 0x7fffff,
      title: title,
      body: summaryText,
      channelId: channelId,
      groupKey: groupKey,
      isGroupSummary: true,
      summaryText: summaryText,
      groupLines: lines,
    ),
  );

  /// Schedules one notification at [when] (device local time).
  ///
  /// Uses an exact alarm only when the exact-alarm permission is granted
  /// (Android 12+); otherwise it falls back to an inexact alarm that the
  /// system may deliver a few minutes late. See [requestExactAlarmPermission].
  Future<ScheduleResult> schedule({
    required String title,
    required String body,
    required DateTime when,
    String channelId = NotificationChannels.remindersId,
    NotificationPayload? payload,
    int? id,
    String? categoryId,
  }) => _schedule(
    title: title,
    body: body,
    when: when,
    repeat: ScheduleRepeat.none,
    channelId: channelId,
    payload: payload,
    id: id,
    categoryId: categoryId,
  );

  /// Repeats every day at [hour]:[minute] (device local time).
  Future<ScheduleResult> scheduleDaily({
    required String title,
    required String body,
    required int hour,
    required int minute,
    String channelId = NotificationChannels.remindersId,
    NotificationPayload? payload,
    int? id,
  }) {
    final now = _now();
    var first = DateTime(now.year, now.month, now.day, hour, minute);
    if (!first.isAfter(now)) {
      first = DateTime(now.year, now.month, now.day + 1, hour, minute);
    }
    return _schedule(
      title: title,
      body: body,
      when: first,
      repeat: ScheduleRepeat.daily,
      channelId: channelId,
      payload: payload,
      id: id,
    );
  }

  /// Repeats every week on [weekday] (`DateTime.monday`..`DateTime.sunday`)
  /// at [hour]:[minute] (device local time).
  Future<ScheduleResult> scheduleWeekly({
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
    String channelId = NotificationChannels.remindersId,
    NotificationPayload? payload,
    int? id,
  }) {
    final now = _now();
    var first = DateTime(now.year, now.month, now.day, hour, minute);
    while (first.weekday != weekday || !first.isAfter(now)) {
      first = DateTime(first.year, first.month, first.day + 1, hour, minute);
    }
    return _schedule(
      title: title,
      body: body,
      when: first,
      repeat: ScheduleRepeat.weekly,
      channelId: channelId,
      payload: payload,
      id: id,
    );
  }

  Future<ScheduleResult> _schedule({
    required String title,
    required String body,
    required DateTime when,
    required ScheduleRepeat repeat,
    required String channelId,
    required NotificationPayload? payload,
    required int? id,
    String? categoryId,
  }) async {
    if (!_settings().isChannelEnabled(channelId)) {
      return ScheduleResult.disabled;
    }
    if (!when.isAfter(_now())) return ScheduleResult.inThePast;
    final exact = await _backend.canScheduleExact();
    if (!exact) {
      _logger.info('Exact alarms not allowed: scheduling inexactly');
    }
    await _backend.schedule(
      ScheduledNotification(
        notification: LocalNotification(
          id: id ?? nextId(),
          title: title,
          body: body,
          channelId: channelId,
          payload: payload,
          categoryId: categoryId,
        ),
        when: when,
        exact: exact,
        repeat: repeat,
      ),
    );
    return exact ? ScheduleResult.exact : ScheduleResult.inexact;
  }

  /// Android 12+: sends the user to the exact-alarm settings. True when exact
  /// alarms are allowed afterwards. Ask only for features that need it.
  Future<bool> requestExactAlarmPermission() =>
      _backend.requestExactAlarmPermission();

  /// Whether [schedule] would use an exact alarm right now.
  Future<bool> canScheduleExact() => _backend.canScheduleExact();

  Future<void> cancel(int id) => _backend.cancel(id);

  Future<void> cancelAll() => _backend.cancelAll();

  /// Scheduled notifications that have not fired yet.
  Future<List<PendingNotification>> pending() => _backend.pending();
}

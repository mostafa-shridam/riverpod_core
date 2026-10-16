import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as m;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone_latest/flutter_native_timezone_latest.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_core/core/helper/deep_link_helper.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationsService {
  static final LocalNotificationsService instance =
      LocalNotificationsService._internal();
  factory LocalNotificationsService() => instance;
  LocalNotificationsService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _enabled = true;

  Future<void> init() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();
      final zone = await FlutterNativeTimezoneLatest.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone));
      log('✅ Timezone set: $zone');

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      await _plugin.initialize(
        settings: const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: (response) async {
          log(
            '🧭 Notification Tap Detected (Foreground) with Payload: ${response.payload}',
          );
          await _handleLocalNotification(response);
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
      await _requestPermissions();
      await _checkAndRequestExactAlarm();
      await handleBackgroundNotification();
      _initialized = true;
      log('✅ LocalNotificationsService initialized');
    } catch (e, s) {
      log('❌ Init error', error: e, stackTrace: s);
    }
  }

  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    if (Platform.isAndroid) {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidImpl?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      final iosImpl = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  bool get enabled => _enabled;

  Future<void> enable() async {
    await _requestPermissions();
    _enabled = true;
    log('🔔 Notifications ENABLED');
  }

  Future<void> disable() async {
    _enabled = false;
    await _plugin.cancelAll();
    log('🔕 Notifications DISABLED & canceled');
  }

  Future<void> toggle(bool value) async =>
      value ? await enable() : await disable();

  Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_enabled) return;
    final id = m.Random().nextInt(1000000);
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details(),
      payload: payload,
    );
  }

  // 1. تعديل ميثود الـ schedule
  Future<void> schedule({
    required String title,
    required String body,
    required String delay,
    String? payload,
    int priority = 1,
  }) async {
    if (!_enabled || delay.isEmpty) return;

    final scheduledDate = DateTime.parse(delay);
    final diff = scheduledDate.difference(DateTime.now());

    if (diff.isNegative) {
      log('🚫 Past date ignored: $delay');
      return;
    }

    final id = scheduledDate.millisecondsSinceEpoch.remainder(123456789);

    log('🔔 Scheduling ID $id in ${diff.inMinutes} mins');

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: _details(priority: _priority(priority)),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: payload,
    );
  }

  Future<void> periodic({
    required String title,
    required String body,
    required RepeatInterval interval,
    String? payload,
  }) async {
    if (!_enabled) return;
    final id = m.Random().nextInt(1000000);
    await _plugin.periodicallyShow(
      id: id,
      title: title,
      body: body,
      repeatInterval: interval,
      notificationDetails: _details(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> _checkAndRequestExactAlarm() async {
    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      final bool? hasPermission = await androidPlugin
          ?.canScheduleExactNotifications();

      if (hasPermission == false) {
        log('❌ Exact alarm permission not granted. Requesting...');

        await androidPlugin?.requestExactAlarmsPermission();
      } else {
        log('✅ Exact alarm permission is already granted');
      }
    }
  }

  NotificationDetails _details({Priority priority = Priority.defaultPriority}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: priority,
        playSound: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
        ticker: 'ticker',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      ),
    );
  }

  Priority _priority(int p) {
    if (p == 0) return Priority.low;
    if (p == 2) return Priority.high;
    return Priority.defaultPriority;
  }

  //handle all local notification
  Future<void> _handleLocalNotification(NotificationResponse response) async {
    final handle = DeepLinkHelper.instance;
    if (response.payload != null) {
      log('🧭 Notification Tap Detected with Payload: ${response.id}');

      unawaited(
        Future<void>.microtask(() async {
          if (response.payload != null && response.payload!.contains('url')) {
            await handle.launchUrl(response.payload ?? '');
          } else {
            await handle.handleRouteById(pyload: response.payload ?? '');
          }
        }),
      );
    }
  }

  Future<void> handleBackgroundNotification() async {
    final details = await _plugin.getNotificationAppLaunchDetails();

    if (details != null &&
        details.didNotificationLaunchApp &&
        details.notificationResponse != null) {
      log(
        '🚀 App launched via Notification with payload: ${details.notificationResponse?.payload}',
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await _handleLocalNotification(details.notificationResponse!);
    }
  }
}

final localNotificationsServiceProvider = Provider<LocalNotificationsService>(
  (ref) => LocalNotificationsService.instance,
);
@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse response) async {
  if (response.payload != null) {
    await DeepLinkHelper.instance.handleRouteById(
      pyload: response.payload ?? '0',
    );
  } else {
    log('No event ID found in the notification data.');
  }
}

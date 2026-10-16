import 'dart:async';

import 'package:riverpod_core/core/config/log_level.dart';
import 'package:riverpod_core/core/device/device_info.dart';
import 'package:riverpod_core/core/device/device_info_source.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';
import 'package:riverpod_core/core/notifications/local/local_notification_backend.dart';
import 'package:riverpod_core/core/notifications/local/timezone_backend.dart';
import 'package:riverpod_core/core/notifications/models/app_notification_channel.dart';
import 'package:riverpod_core/core/notifications/models/app_notification_channel_group.dart';
import 'package:riverpod_core/core/notifications/models/local_notification.dart';
import 'package:riverpod_core/core/notifications/models/notification_permission_state.dart';
import 'package:riverpod_core/core/notifications/models/notification_tap.dart';
import 'package:riverpod_core/core/notifications/models/pending_notification.dart';
import 'package:riverpod_core/core/notifications/models/push_message.dart';
import 'package:riverpod_core/core/notifications/models/scheduled_notification.dart';
import 'package:riverpod_core/core/notifications/push/push_backend.dart';
import 'package:riverpod_core/core/notifications/registration/push_token_registrar.dart';
import 'package:riverpod_core/core/notifications/registration/push_token_registration.dart';
import 'package:riverpod_core/core/permissions/app_permission.dart';
import 'package:riverpod_core/core/permissions/permission_service.dart';

/// In-memory [LocalNotificationBackend] that records every call.
class FakeLocalNotificationBackend implements LocalNotificationBackend {
  String? timezoneName;
  NotificationTapCallback? onTap;
  List<AppNotificationChannel> channels = [];
  List<AppNotificationChannelGroup> groups = [];
  int createChannelsCalls = 0;
  NotificationTap? launch;
  bool exactAllowed = true;
  bool failInitialize = false;

  final List<LocalNotification> shown = [];
  final List<ScheduledNotification> scheduled = [];
  final List<int> cancelled = [];
  final List<int> badges = [];
  int cancelAllCalls = 0;
  int exactRequests = 0;

  @override
  Future<void> initialize({
    required String timezoneName,
    required NotificationTapCallback onTap,
  }) async {
    if (failInitialize) throw StateError('init failed');
    this.timezoneName = timezoneName;
    this.onTap = onTap;
  }

  @override
  Future<void> createChannels({
    required List<AppNotificationChannel> channels,
    required List<AppNotificationChannelGroup> groups,
    required NotificationLabelResolver label,
  }) async {
    createChannelsCalls++;
    this.channels = channels;
    this.groups = groups;
  }

  @override
  Future<NotificationTap?> launchTap() async => launch;

  @override
  Future<void> show(LocalNotification notification) async =>
      shown.add(notification);

  @override
  Future<void> schedule(ScheduledNotification scheduled) async =>
      this.scheduled.add(scheduled);

  @override
  Future<void> cancel(int id) async => cancelled.add(id);

  @override
  Future<void> cancelAll() async => cancelAllCalls++;

  @override
  Future<List<PendingNotification>> pending() async => [
    for (final item in scheduled)
      PendingNotification(
        id: item.notification.id,
        title: item.notification.title,
        body: item.notification.body,
      ),
  ];

  @override
  Future<bool> canScheduleExact() async => exactAllowed;

  @override
  Future<bool> requestExactAlarmPermission() async {
    exactRequests++;
    return exactAllowed;
  }

  @override
  Future<void> setBadge(int count) async => badges.add(count);
}

/// Scriptable [PushBackend].
class FakePushBackend implements PushBackend {
  bool available = true;
  bool failInitialize = false;
  String? currentToken = 'token-1';
  PushMessage? initial;
  NotificationPermissionState permissionState =
      NotificationPermissionState.granted;

  final messages = StreamController<PushMessage>.broadcast();
  final opened = StreamController<PushMessage>.broadcast();
  final refreshes = StreamController<String>.broadcast();

  int initializeCalls = 0;
  int deleteTokenCalls = 0;
  final List<String> subscribed = [];
  final List<String> unsubscribed = [];
  final List<bool> presentation = [];
  final List<bool> permissionRequests = [];

  @override
  Future<bool> initialize() async {
    initializeCalls++;
    if (failInitialize) throw StateError('no firebase');
    return available;
  }

  @override
  Stream<PushMessage> get onMessage => messages.stream;

  @override
  Stream<PushMessage> get onMessageOpenedApp => opened.stream;

  @override
  Future<PushMessage?> initialMessage() async => initial;

  @override
  Future<String?> token() async => currentToken;

  @override
  Stream<String> get onTokenRefresh => refreshes.stream;

  @override
  Future<void> deleteToken() async {
    deleteTokenCalls++;
    currentToken = null;
  }

  @override
  Future<void> subscribe(String topic) async => subscribed.add(topic);

  @override
  Future<void> unsubscribe(String topic) async => unsubscribed.add(topic);

  @override
  Future<NotificationPermissionState> permission() async => permissionState;

  @override
  Future<NotificationPermissionState> requestPermission({
    bool provisional = false,
  }) async {
    permissionRequests.add(provisional);
    return permissionState;
  }

  @override
  Future<void> setForegroundPresentation({required bool enabled}) async =>
      presentation.add(enabled);
}

/// Scriptable [PermissionBackend] for [AppPermission.notifications]: the state
/// the notification service sees comes from the shared permission flow.
class FakeNotificationPermissionBackend implements PermissionBackend {
  FakeNotificationPermissionBackend([this.state = AppPermissionResult.denied]);

  AppPermissionResult state;

  /// What `request()` leaves the state at.
  AppPermissionResult requestResult = AppPermissionResult.granted;
  bool rationale = false;
  int requests = 0;
  int settingsOpened = 0;

  @override
  Future<AppPermissionResult> status(AppPermission permission) async => state;

  @override
  Future<AppPermissionResult> request(AppPermission permission) async {
    requests++;
    return state = requestResult;
  }

  @override
  Future<bool> shouldShowRationale(AppPermission permission) async => rationale;

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return true;
  }
}

/// Fixed time zone.
class FakeTimezoneBackend implements TimezoneBackend {
  FakeTimezoneBackend([this.zone = 'Africa/Cairo']);

  final String? zone;

  @override
  Future<String?> localTimezone() async => zone;
}

/// Records registrations; can be made to fail.
class FakePushTokenRegistrar implements PushTokenRegistrar {
  final List<PushTokenRegistration> registrations = [];
  final List<String> unregistered = [];
  Object? failWith;

  @override
  Future<void> register(PushTokenRegistration registration) async {
    if (failWith != null) throw failWith!;
    registrations.add(registration);
  }

  @override
  Future<void> unregister(String token) async {
    if (failWith != null) throw failWith!;
    unregistered.add(token);
  }
}

/// Fixed device facts.
class FakeDeviceInfoSource implements DeviceInfoSource {
  @override
  Future<String> platform() async => 'android';

  @override
  Future<String> model() async => 'Pixel Test';

  @override
  Future<String> osVersion() async => '14';
}

/// A [DeviceInfo] for tests.
const testDevice = DeviceInfo(
  platform: 'android',
  model: 'Pixel Test',
  osVersion: '14',
  installationId: 'install-1',
);

/// An [AppLogger] that appends `level: message` to [out].
AppLogger recordingLogger(List<String> out) => AppLogger(
  level: LogLevel.debug,
  sink: (level, message, error, stackTrace) =>
      out.add('${level.name}: $message'),
);

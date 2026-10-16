import 'package:riverpod_core/core/notifications/models/app_notification_channel.dart';
import 'package:riverpod_core/core/notifications/models/app_notification_channel_group.dart';
import 'package:riverpod_core/core/notifications/models/local_notification.dart';
import 'package:riverpod_core/core/notifications/models/notification_tap.dart';
import 'package:riverpod_core/core/notifications/models/pending_notification.dart';
import 'package:riverpod_core/core/notifications/models/scheduled_notification.dart';

/// Receives a tap on a local notification.
typedef NotificationTapCallback = void Function(NotificationTap tap);

/// Turns a `LocaleKeys` constant into text.
typedef NotificationLabelResolver = String Function(String key);

/// The platform side of local notifications. Tests use a fake, so no platform
/// channel is needed.
abstract interface class LocalNotificationBackend {
  /// Sets up the plugin and the time zone [timezoneName] used by scheduling.
  /// [onTap] receives every tap and action press while the app runs.
  Future<void> initialize({
    required String timezoneName,
    required NotificationTapCallback onTap,
  });

  /// Creates or updates the Android channels and groups. Safe to repeat:
  /// the system keeps the user's settings and refreshes the names.
  Future<void> createChannels({
    required List<AppNotificationChannel> channels,
    required List<AppNotificationChannelGroup> groups,
    required NotificationLabelResolver label,
  });

  /// The tap that started the app from a terminated state, if any.
  Future<NotificationTap?> launchTap();

  Future<void> show(LocalNotification notification);

  Future<void> schedule(ScheduledNotification scheduled);

  Future<void> cancel(int id);

  Future<void> cancelAll();

  Future<List<PendingNotification>> pending();

  /// Android 12+: whether exact alarms may be scheduled. True elsewhere.
  Future<bool> canScheduleExact();

  /// Android 12+: opens the exact-alarm settings; true when it is allowed.
  Future<bool> requestExactAlarmPermission();

  /// iOS: writes [count] on the app icon. No-op elsewhere.
  Future<void> setBadge(int count);
}

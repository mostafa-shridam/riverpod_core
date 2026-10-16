import 'package:riverpod_core/core/notifications/models/app_notification_channel.dart';
import 'package:riverpod_core/core/notifications/models/app_notification_channel_group.dart';
import 'package:riverpod_core/core/notifications/models/notification_importance.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// The ONE table of Android notification channels. Add a channel here and it
/// is created at startup, gets a per-channel user switch and is documented in
/// the system settings. Ids are permanent: never rename a shipped id.
abstract final class NotificationChannels {
  static const updatesGroup = AppNotificationChannelGroup(
    id: 'updates',
    nameKey: LocaleKeys.notifications_groupUpdates,
  );

  static const remindersGroup = AppNotificationChannelGroup(
    id: 'reminders_group',
    nameKey: LocaleKeys.notifications_groupReminders,
  );

  /// Default channel: anything without a better fit.
  static const general = AppNotificationChannel(
    id: 'general',
    nameKey: LocaleKeys.notifications_channelGeneralName,
    descriptionKey: LocaleKeys.notifications_channelGeneralDescription,
    groupId: 'updates',
  );

  /// Heads-up alerts: use sparingly, users switch off noisy apps.
  static const highPriority = AppNotificationChannel(
    id: 'high_priority',
    nameKey: LocaleKeys.notifications_channelHighPriorityName,
    descriptionKey: LocaleKeys.notifications_channelHighPriorityDescription,
    importance: NotificationImportance.max,
    groupId: 'updates',
  );

  /// Shown in the shade without sound, vibration or badge.
  static const silent = AppNotificationChannel(
    id: 'silent',
    nameKey: LocaleKeys.notifications_channelSilentName,
    descriptionKey: LocaleKeys.notifications_channelSilentDescription,
    importance: NotificationImportance.low,
    playSound: false,
    enableVibration: false,
    showBadge: false,
    groupId: 'updates',
  );

  /// User-requested reminders (scheduled notifications).
  static const reminders = AppNotificationChannel(
    id: remindersId,
    nameKey: LocaleKeys.notifications_channelRemindersName,
    descriptionKey: LocaleKeys.notifications_channelRemindersDescription,
    importance: NotificationImportance.high,
    groupId: 'reminders_group',
  );

  /// Channel of scheduled, user-requested notifications.
  static const remindersId = 'reminders';

  static const groups = [updatesGroup, remindersGroup];

  static const all = [general, highPriority, silent, reminders];

  /// Id used when a message names no channel or an unknown one. Must equal
  /// `default_notification_channel_id` in AndroidManifest.xml.
  static const defaultChannelId = 'general';

  /// True when [id] is a channel of [all].
  static bool isKnown(String? id) => all.any((channel) => channel.id == id);

  /// The channel for [id], or [general] when unknown or null.
  static AppNotificationChannel byId(String? id) =>
      all.firstWhere((channel) => channel.id == id, orElse: () => general);
}

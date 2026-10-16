import 'package:flutter/foundation.dart';
import 'package:riverpod_core/core/notifications/models/notification_importance.dart';

/// One Android notification channel. [nameKey] and [descriptionKey] are
/// `LocaleKeys`; they are resolved when the channel is created because the
/// channel names are shown in the system settings.
@immutable
class AppNotificationChannel {
  const AppNotificationChannel({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    this.importance = NotificationImportance.normal,
    this.playSound = true,
    this.enableVibration = true,
    this.showBadge = true,
    this.groupId,
  });

  /// Stable id. Never change a shipped id: users keep per-channel settings.
  final String id;
  final String nameKey;
  final String descriptionKey;
  final NotificationImportance importance;
  final bool playSound;
  final bool enableVibration;
  final bool showBadge;

  /// Id of an [AppNotificationChannelGroup], or null.
  final String? groupId;
}

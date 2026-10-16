import 'package:flutter/foundation.dart';
import 'package:riverpod_core/core/notifications/models/notification_payload.dart';

/// A notification to show now. Titles and bodies are already localized by the
/// caller.
@immutable
class LocalNotification {
  const LocalNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.channelId,
    this.payload,
    this.bigText,
    this.bigPicturePath,
    this.groupKey,
    this.isGroupSummary = false,
    this.summaryText,
    this.groupLines = const [],
    this.badge,
    this.categoryId,
  });

  final int id;
  final String title;
  final String body;
  final String channelId;
  final NotificationPayload? payload;

  /// Android: expanded text (BigText style).
  final String? bigText;

  /// Android: path of a local image shown expanded (BigPicture style).
  final String? bigPicturePath;

  /// Android: notifications with the same key are stacked together.
  final String? groupKey;

  /// Android: this notification is the summary of its [groupKey].
  final bool isGroupSummary;

  /// Android: text of the summary row.
  final String? summaryText;

  /// Android: lines of the summary (Inbox style).
  final List<String> groupLines;

  /// iOS: number written on the app icon.
  final int? badge;

  /// iOS: category id registered at init, for action buttons.
  final String? categoryId;
}

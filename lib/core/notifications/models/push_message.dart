import 'package:flutter/foundation.dart';
import 'package:riverpod_core/core/notifications/models/notification_payload.dart';

/// A push message, independent of `firebase_messaging`.
@immutable
class PushMessage {
  const PushMessage({
    this.id,
    this.title,
    this.body,
    this.imageUrl,
    this.channelId,
    this.data = const {},
  });

  /// FCM message id, used to drop duplicates. May be null.
  final String? id;
  final String? title;
  final String? body;
  final String? imageUrl;

  /// Android channel the sender asked for, if any.
  final String? channelId;
  final Map<String, Object?> data;

  /// True for notification and notification+data messages; false for a
  /// data-only (silent) message, which the app must handle itself.
  bool get hasNotification => title != null || body != null;

  /// The payload contract read from [data].
  NotificationPayload get payload => NotificationPayload.fromData(data);
}

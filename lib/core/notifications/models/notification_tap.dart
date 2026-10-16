import 'package:flutter/foundation.dart';
import 'package:riverpod_core/core/notifications/models/notification_payload.dart';
import 'package:riverpod_core/core/notifications/models/notification_tap_source.dart';

/// A user interaction with a notification, whatever produced it.
@immutable
class NotificationTap {
  const NotificationTap({
    required this.payload,
    required this.source,
    this.actionId,
    this.input,
  });

  final NotificationPayload payload;
  final NotificationTapSource source;

  /// Id of the pressed action button; null for a tap on the body.
  final String? actionId;

  /// Text typed into an inline-reply action, if any.
  final String? input;
}

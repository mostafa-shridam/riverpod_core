import 'package:flutter/foundation.dart';

/// A scheduled notification that has not been shown yet.
@immutable
class PendingNotification {
  const PendingNotification({
    required this.id,
    this.title,
    this.body,
    this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

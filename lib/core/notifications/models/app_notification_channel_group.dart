import 'package:flutter/foundation.dart';

/// A group of channels, shown as one section in the system settings.
@immutable
class AppNotificationChannelGroup {
  const AppNotificationChannelGroup({required this.id, required this.nameKey});

  final String id;
  final String nameKey;
}

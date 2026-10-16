import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/widgets/feedback/app_status_type.dart';

/// Where a toast floats.
enum AppToastPosition { top, bottom }

/// One message waiting in (or shown by) the `AppMessenger`.
@immutable
class AppMessage {
  const AppMessage({
    required this.message,
    this.type = AppStatusType.info,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.position = AppToastPosition.bottom,
    this.duration,
  });

  final String message;
  final AppStatusType type;

  /// Replaces the default icon of [type].
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final AppToastPosition position;

  /// How long it stays; null derives a readable time from the motion tokens.
  final Duration? duration;
}

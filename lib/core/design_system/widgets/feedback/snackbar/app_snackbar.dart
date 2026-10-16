import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_core/core/design_system/widgets/feedback/app_status_type.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/snackbar/app_message.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/snackbar/app_messenger.dart';

/// Floating message at the bottom (default) with an optional action.
/// Needs a `ProviderScope` above [context]. Messages queue, one at a time;
/// [replaceCurrent] jumps the queue.
void showAppSnackbar(
  BuildContext context, {
  required String message,
  AppStatusType type = AppStatusType.info,
  IconData? icon,
  String? actionLabel,
  VoidCallback? onAction,
  AppToastPosition position = AppToastPosition.bottom,
  Duration? duration,
  bool replaceCurrent = false,
}) {
  ProviderScope.containerOf(context, listen: false)
      .read(appMessengerProvider)
      .show(
        AppMessage(
          message: message,
          type: type,
          icon: icon,
          actionLabel: actionLabel,
          onAction: onAction,
          position: position,
          duration: duration,
        ),
        context: context,
        replaceCurrent: replaceCurrent,
      );
}

/// Same queue as [showAppSnackbar] but floats at the top by default, which
/// keeps it clear of bottom bars and keyboards.
void showAppToast(
  BuildContext context, {
  required String message,
  AppStatusType type = AppStatusType.info,
  IconData? icon,
  String? actionLabel,
  VoidCallback? onAction,
  AppToastPosition position = AppToastPosition.top,
  Duration? duration,
  bool replaceCurrent = false,
}) {
  showAppSnackbar(
    context,
    message: message,
    type: type,
    icon: icon,
    actionLabel: actionLabel,
    onAction: onAction,
    position: position,
    duration: duration,
    replaceCurrent: replaceCurrent,
  );
}

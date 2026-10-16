import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/widgets/dialogs/app_dialog.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/app_status_type.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Single-button alert with an info / success / warning / error icon.
class AppAlertDialog extends StatelessWidget {
  const AppAlertDialog({
    required this.title,
    super.key,
    this.message,
    this.type = AppStatusType.info,
    this.confirmLabel,
    this.onConfirm,
  });

  final String title;
  final String? message;
  final AppStatusType type;

  /// Overrides the localized "OK" label.
  final String? confirmLabel;

  /// Called after the dialog closes.
  final VoidCallback? onConfirm;

  /// Opens the alert and completes when it closes.
  static Future<void> show({
    required BuildContext context,
    required String title,
    String? message,
    AppStatusType type = AppStatusType.info,
    String? confirmLabel,
    VoidCallback? onConfirm,
    bool barrierDismissible = true,
  }) {
    return showAppDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => AppAlertDialog(
        title: title,
        message: message,
        type: type,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDialogFrame(
      title: title,
      message: message,
      status: type,
      primary: FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, kMinInteractiveDimension),
        ),
        onPressed: () {
          Navigator.of(context).pop();
          onConfirm?.call();
        },
        child: Text(confirmLabel ?? LocaleKeys.ds_overlays_ok.tr()),
      ),
    );
  }
}

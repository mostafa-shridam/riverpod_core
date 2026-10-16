import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/widgets/dialogs/app_dialog.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/app_status_type.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Confirm / cancel dialog. Pops `true` on confirm, `false` otherwise.
/// [isDestructive] paints the confirm button with the error color and shows a
/// warning icon unless [type] says otherwise.
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    required this.title,
    super.key,
    this.message,
    this.isDestructive = false,
    this.type,
    this.confirmLabel,
    this.cancelLabel,
  });

  final String title;
  final String? message;
  final bool isDestructive;
  final AppStatusType? type;
  final String? confirmLabel;
  final String? cancelLabel;

  /// Opens the dialog; a dismissed dialog counts as `false`.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    String? message,
    bool isDestructive = false,
    AppStatusType? type,
    String? confirmLabel,
    String? cancelLabel,
    bool barrierDismissible = true,
  }) async {
    final result = await showAppDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => AppConfirmDialog(
        title: title,
        message: message,
        isDestructive: isDestructive,
        type: type,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const minSize = Size(0, kMinInteractiveDimension);
    return AppDialogFrame(
      title: title,
      message: message,
      status: type ?? (isDestructive ? AppStatusType.warning : null),
      primary: FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: minSize,
          backgroundColor: isDestructive ? scheme.error : null,
          foregroundColor: isDestructive ? scheme.onError : null,
        ),
        onPressed: () => Navigator.of(context).pop(true),
        child: Text(confirmLabel ?? LocaleKeys.ds_overlays_confirm.tr()),
      ),
      secondary: TextButton(
        style: TextButton.styleFrom(minimumSize: minSize),
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(cancelLabel ?? LocaleKeys.ds_overlays_cancel.tr()),
      ),
    );
  }
}

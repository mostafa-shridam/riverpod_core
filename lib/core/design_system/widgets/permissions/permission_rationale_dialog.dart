import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/widgets/dialogs/app_dialog.dart';
import 'package:riverpod_core/core/design_system/widgets/permissions/permissions_strings.dart';
import 'package:riverpod_core/core/permissions/app_permission.dart';
import 'package:riverpod_core/core/permissions/permission_rationale.dart';

/// Explains why a permission is needed. Pops `true` when the user accepts
/// ("Allow", or "Open settings" when [openSettings]) and `false` otherwise.
class PermissionRationaleDialog extends StatelessWidget {
  const PermissionRationaleDialog({
    required this.permission,
    super.key,
    this.openSettings = false,
    this.title,
    this.message,
    this.confirmLabel,
    this.cancelLabel,
  });

  final AppPermission permission;

  /// Permanently denied: the confirm action leads to the system settings.
  final bool openSettings;

  /// Optional overrides of the localized texts.
  final String? title;
  final String? message;
  final String? confirmLabel;
  final String? cancelLabel;

  static IconData _iconOf(AppPermission permission) => switch (permission) {
    AppPermission.camera => Icons.photo_camera_rounded,
    AppPermission.photos => Icons.photo_library_rounded,
    AppPermission.microphone => Icons.mic_rounded,
  };

  @override
  Widget build(BuildContext context) {
    const minSize = Size(0, kMinInteractiveDimension);
    final body = message ?? permissionMessageKey(permission).tr();
    return AppDialogFrame(
      icon: _iconOf(permission),
      title: title ?? permissionTitleKey(permission).tr(),
      message: openSettings
          ? '$body\n\n${permissionSettingsHintKey.tr()}'
          : body,
      primary: FilledButton(
        style: FilledButton.styleFrom(minimumSize: minSize),
        onPressed: () => Navigator.of(context).pop(true),
        child: Text(
          confirmLabel ??
              (openSettings ? permissionOpenSettingsKey : permissionAllowKey)
                  .tr(),
        ),
      ),
      secondary: TextButton(
        style: TextButton.styleFrom(minimumSize: minSize),
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(cancelLabel ?? permissionNotNowKey.tr()),
      ),
    );
  }
}

/// A [PermissionRationalePresenter] backed by [PermissionRationaleDialog]:
/// override `permissionRationalePresenterProvider` with this tear-off in
/// `app/`. A dismissed dialog counts as declined.
Future<bool> showPermissionRationale(
  BuildContext context,
  PermissionRationaleRequest request,
) async {
  final accepted = await showAppDialog<bool>(
    context: context,
    builder: (_) => PermissionRationaleDialog(
      permission: request.permission,
      openSettings: request.openSettings,
    ),
  );
  return accepted ?? false;
}

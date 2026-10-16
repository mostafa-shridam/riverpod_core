import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/widgets/dialogs/app_dialog.dart';
import 'package:riverpod_core/core/permissions/app_permission.dart';
import 'package:riverpod_core/core/permissions/permission_rationale.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

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
    final body = message ?? _messageKey(permission).tr();
    return AppDialogFrame(
      icon: _iconOf(permission),
      title: title ?? _titleKey(permission).tr(),
      message: openSettings
          ? '$body\n\n${LocaleKeys.ds_permissions_settingsHint.tr()}'
          : body,
      primary: FilledButton(
        style: FilledButton.styleFrom(minimumSize: minSize),
        onPressed: () => Navigator.of(context).pop(true),
        child: Text(
          confirmLabel ??
              (openSettings
                      ? LocaleKeys.ds_permissions_openSettings
                      : LocaleKeys.ds_permissions_allow)
                  .tr(),
        ),
      ),
      secondary: TextButton(
        style: TextButton.styleFrom(minimumSize: minSize),
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(cancelLabel ?? LocaleKeys.ds_permissions_notNow.tr()),
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

/// Title key per permission. A switch, so a new [AppPermission] fails to compile
/// until it has its copy.
String _titleKey(AppPermission permission) => switch (permission) {
  AppPermission.camera => LocaleKeys.ds_permissions_cameraTitle,
  AppPermission.photos => LocaleKeys.ds_permissions_photosTitle,
  AppPermission.microphone => LocaleKeys.ds_permissions_microphoneTitle,
};

/// Message key per permission (see [_titleKey]).
String _messageKey(AppPermission permission) => switch (permission) {
  AppPermission.camera => LocaleKeys.ds_permissions_cameraMessage,
  AppPermission.photos => LocaleKeys.ds_permissions_photosMessage,
  AppPermission.microphone => LocaleKeys.ds_permissions_microphoneMessage,
};

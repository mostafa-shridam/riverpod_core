import 'package:flutter/widgets.dart';

import 'package:riverpod_core/core/permissions/app_permission.dart';

/// What the UI is asked to explain before the system prompt or before sending
/// the user to the system settings.
@immutable
class PermissionRationaleRequest {
  const PermissionRationaleRequest({
    required this.permission,
    required this.openSettings,
  });

  final AppPermission permission;

  /// True when the permission is permanently denied: the confirm action opens
  /// the system settings instead of showing the system prompt.
  final bool openSettings;
}

/// Shows the rationale and returns true when the user accepts. Implemented by
/// the design system (`showPermissionRationale`); `core/` never imports UI, so
/// the app wires it through `permissionRationalePresenterProvider`.
typedef PermissionRationalePresenter =
    Future<bool> Function(
      BuildContext context,
      PermissionRationaleRequest request,
    );

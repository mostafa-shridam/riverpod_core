import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:riverpod_core/core/permissions/app_permission.dart';
import 'package:riverpod_core/core/permissions/permission_rationale.dart';

part 'permission_service.g.dart';

/// The platform side of permissions. Tests implement it with a fake, so no
/// platform channel is needed.
abstract interface class PermissionBackend {
  Future<AppPermissionResult> status(AppPermission permission);

  Future<AppPermissionResult> request(AppPermission permission);

  /// Android only: true when the system advises explaining first.
  Future<bool> shouldShowRationale(AppPermission permission);

  Future<bool> openSettings();
}

/// [PermissionBackend] over `permission_handler`.
class PermissionHandlerBackend implements PermissionBackend {
  const PermissionHandlerBackend();

  ph.Permission _of(AppPermission permission) => switch (permission) {
    AppPermission.camera => ph.Permission.camera,
    AppPermission.photos => ph.Permission.photos,
    AppPermission.microphone => ph.Permission.microphone,
  };

  AppPermissionResult _map(ph.PermissionStatus status) => switch (status) {
    ph.PermissionStatus.granted ||
    ph.PermissionStatus.provisional => AppPermissionResult.granted,
    ph.PermissionStatus.denied => AppPermissionResult.denied,
    ph.PermissionStatus.permanentlyDenied =>
      AppPermissionResult.permanentlyDenied,
    ph.PermissionStatus.restricted => AppPermissionResult.restricted,
    ph.PermissionStatus.limited => AppPermissionResult.limited,
  };

  @override
  Future<AppPermissionResult> status(AppPermission permission) async =>
      _map(await _of(permission).status);

  @override
  Future<AppPermissionResult> request(AppPermission permission) async =>
      _map(await _of(permission).request());

  @override
  Future<bool> shouldShowRationale(AppPermission permission) =>
      _of(permission).shouldShowRequestRationale;

  @override
  Future<bool> openSettings() => ph.openAppSettings();
}

/// Checks and requests permissions, explaining first when it helps.
class PermissionService {
  const PermissionService({
    PermissionBackend backend = const PermissionHandlerBackend(),
    this.presenter,
  }) : _backend = backend;

  final PermissionBackend _backend;

  /// Shows the rationale UI; without it the flow skips the explanation.
  final PermissionRationalePresenter? presenter;

  /// Current state, without prompting.
  Future<AppPermissionResult> status(AppPermission permission) =>
      _backend.status(permission);

  /// System prompt, without any explanation.
  Future<AppPermissionResult> request(AppPermission permission) =>
      _backend.request(permission);

  /// Makes sure [permission] is usable, asking the user when needed.
  ///
  /// - already granted/limited/restricted: returned as is, nothing shown;
  /// - denied: shows the rationale first when the system advises it, then the
  ///   system prompt;
  /// - permanently denied: shows the rationale with an "Open settings" action
  ///   and opens the settings on accept. The result is still
  ///   `permanentlyDenied`: re-check with [status] when the app resumes.
  Future<AppPermissionResult> ensure(
    AppPermission permission,
    BuildContext context,
  ) async {
    final current = await _backend.status(permission);
    switch (current) {
      case AppPermissionResult.granted ||
          AppPermissionResult.limited ||
          AppPermissionResult.restricted:
        return current;
      case AppPermissionResult.permanentlyDenied:
        if (!context.mounted) return current;
        final accepted = await _explain(permission, context, true);
        if (accepted) await _backend.openSettings();
        return current;
      case AppPermissionResult.denied:
        if (presenter != null &&
            await _backend.shouldShowRationale(permission)) {
          if (!context.mounted) return current;
          final accepted = await _explain(permission, context, false);
          if (!accepted) return current;
        }
        return _backend.request(permission);
    }
  }

  Future<bool> _explain(
    AppPermission permission,
    BuildContext context,
    bool openSettings,
  ) async {
    final show = presenter;
    if (show == null || !context.mounted) return false;
    return show(
      context,
      PermissionRationaleRequest(
        permission: permission,
        openSettings: openSettings,
      ),
    );
  }
}

/// The app wires the design-system dialog here (override in `app/`). Null
/// means no rationale UI.
@Riverpod(keepAlive: true)
PermissionRationalePresenter? permissionRationalePresenter(Ref ref) => null;

/// Backend seam: override in tests with a fake.
@Riverpod(keepAlive: true)
PermissionBackend permissionBackend(Ref ref) =>
    const PermissionHandlerBackend();

/// The one [PermissionService] of the app.
@Riverpod(keepAlive: true)
PermissionService permissionService(Ref ref) => PermissionService(
  backend: ref.watch(permissionBackendProvider),
  presenter: ref.watch(permissionRationalePresenterProvider),
);

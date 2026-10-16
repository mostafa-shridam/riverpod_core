import 'package:flutter/widgets.dart';
import 'package:riverpod_core/core/notifications/models/notification_permission_state.dart';
import 'package:riverpod_core/core/notifications/permission/notification_permission_backend.dart';

/// Shows the rationale and returns true when the user accepts. [openSettings]
/// is true when the permission is permanently denied: accepting then opens the
/// system settings instead of the system prompt. The app wires the design
/// system dialog through `notificationRationalePresenterProvider`.
typedef NotificationRationalePresenter =
    Future<bool> Function(BuildContext context, {required bool openSettings});

/// Asks for the notification permission, explaining first when it helps. It
/// mirrors `PermissionService.ensure` for the notification permission.
class NotificationPermissionFlow {
  const NotificationPermissionFlow({
    required NotificationPermissionBackend backend,
    this.presenter,
  }) : _backend = backend;

  final NotificationPermissionBackend _backend;

  /// Shows the rationale UI; without it the explanation step is skipped.
  final NotificationRationalePresenter? presenter;

  /// Current state, without prompting.
  Future<NotificationPermissionState> status() => _backend.status();

  /// Opens the system settings of this app.
  Future<bool> openSettings() => _backend.openSettings();

  /// Makes sure notifications are allowed, asking the user when needed.
  ///
  /// - granted or provisional: returned, nothing shown;
  /// - denied: the rationale first when the system advises it (Android), then
  ///   the system prompt;
  /// - permanently denied: the rationale with an "open settings" action; the
  ///   settings open on accept and the state is returned as it was. Re-read
  ///   [status] when the app resumes.
  Future<NotificationPermissionState> ensure(BuildContext context) async {
    final current = await _backend.status();
    switch (current) {
      case NotificationPermissionState.granted ||
          NotificationPermissionState.provisional:
        return current;
      case NotificationPermissionState.permanentlyDenied:
        if (!context.mounted) return current;
        if (await _explain(context, openSettings: true)) {
          await _backend.openSettings();
        }
        return current;
      case NotificationPermissionState.denied:
        if (presenter != null && await _backend.shouldShowRationale()) {
          if (!context.mounted) return current;
          if (!await _explain(context, openSettings: false)) return current;
        }
        return _backend.request();
    }
  }

  Future<bool> _explain(
    BuildContext context, {
    required bool openSettings,
  }) async {
    final show = presenter;
    if (show == null || !context.mounted) return false;
    return show(context, openSettings: openSettings);
  }
}

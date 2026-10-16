import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:riverpod_core/core/notifications/models/notification_permission_state.dart';
import 'package:riverpod_core/core/notifications/permission/notification_permission_backend.dart';

/// [NotificationPermissionBackend] over `permission_handler`. On iOS the
/// request asks for alert, badge and sound (the `PERMISSION_NOTIFICATIONS`
/// macro of the Podfile must be on).
class PlatformNotificationPermissionBackend
    implements NotificationPermissionBackend {
  const PlatformNotificationPermissionBackend();

  NotificationPermissionState _map(
    ph.PermissionStatus status,
  ) => switch (status) {
    ph.PermissionStatus.granted ||
    ph.PermissionStatus.limited => NotificationPermissionState.granted,
    ph.PermissionStatus.provisional => NotificationPermissionState.provisional,
    ph.PermissionStatus.denied => NotificationPermissionState.denied,
    ph.PermissionStatus.permanentlyDenied || ph.PermissionStatus.restricted =>
      NotificationPermissionState.permanentlyDenied,
  };

  @override
  Future<NotificationPermissionState> status() async =>
      _map(await ph.Permission.notification.status);

  @override
  Future<NotificationPermissionState> request() async =>
      _map(await ph.Permission.notification.request());

  @override
  Future<bool> shouldShowRationale() =>
      ph.Permission.notification.shouldShowRequestRationale;

  @override
  Future<bool> openSettings() => ph.openAppSettings();
}

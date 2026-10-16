import 'package:riverpod_core/core/notifications/models/notification_permission_state.dart';
import 'package:riverpod_core/core/permissions/app_permission.dart';

/// The notification view of the shared [AppPermissionResult] of
/// [AppPermission.notifications] (D-039 item 3). There is one permission flow,
/// [PermissionService]; this only names its outcome for the notification UI.
NotificationPermissionState notificationStateOf(AppPermissionResult result) =>
    switch (result) {
      AppPermissionResult.granted ||
      AppPermissionResult.limited => NotificationPermissionState.granted,
      AppPermissionResult.provisional =>
        NotificationPermissionState.provisional,
      AppPermissionResult.denied => NotificationPermissionState.denied,
      AppPermissionResult.permanentlyDenied || AppPermissionResult.restricted =>
        NotificationPermissionState.permanentlyDenied,
    };

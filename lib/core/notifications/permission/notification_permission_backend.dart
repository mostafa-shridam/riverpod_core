import 'package:riverpod_core/core/notifications/models/notification_permission_state.dart';

/// The platform side of the notification permission. Tests use a fake, so no
/// platform channel is needed.
abstract interface class NotificationPermissionBackend {
  /// Current state, without prompting.
  Future<NotificationPermissionState> status();

  /// Shows the system prompt (Android 13+ `POST_NOTIFICATIONS`, iOS alert,
  /// badge and sound) and returns the new state.
  Future<NotificationPermissionState> request();

  /// Android only: true when the system advises explaining first.
  Future<bool> shouldShowRationale();

  /// Opens the system settings of this app.
  Future<bool> openSettings();
}

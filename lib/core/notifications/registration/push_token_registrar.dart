import 'package:riverpod_core/core/notifications/registration/push_token_registration.dart';

/// Tells the app's backend which FCM token belongs to the signed-in user. The
/// template never writes to Firebase databases; the backend is the app's own.
///
/// Implement it for the real API and override `pushTokenRegistrarProvider`.
/// Failures may throw: the caller logs them and retries at the next sign-in,
/// token refresh or settings change.
abstract interface class PushTokenRegistrar {
  /// Registers or updates the token of the signed-in user.
  Future<void> register(PushTokenRegistration registration);

  /// Removes [token] from the user, so the server stops sending to it. Called
  /// while the session is still valid (before logout clears the tokens).
  Future<void> unregister(String token);
}

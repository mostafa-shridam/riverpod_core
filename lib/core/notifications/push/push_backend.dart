import 'package:riverpod_core/core/notifications/models/notification_permission_state.dart';
import 'package:riverpod_core/core/notifications/models/push_message.dart';

/// The platform side of push (Firebase Cloud Messaging). Tests use a fake, so
/// no platform channel and no Firebase project are needed.
abstract interface class PushBackend {
  /// Starts Firebase and registers the background handler. Returns false
  /// (never throws) when push is unavailable: no Firebase config in the app,
  /// or the platform does not support FCM.
  Future<bool> initialize();

  /// Messages received while the app is in the foreground.
  Stream<PushMessage> get onMessage;

  /// A notification tapped while the app was in the background.
  Stream<PushMessage> get onMessageOpenedApp;

  /// The message whose notification started the app from terminated, once.
  Future<PushMessage?> initialMessage();

  /// The current FCM token, or null when none is available yet.
  Future<String?> token();

  /// Fires with every new token.
  Stream<String> get onTokenRefresh;

  /// Invalidates the token so the server can no longer reach this install.
  Future<void> deleteToken();

  Future<void> subscribe(String topic);

  Future<void> unsubscribe(String topic);

  /// Current OS permission as FCM sees it.
  Future<NotificationPermissionState> permission();

  /// Asks FCM for the permission (it also registers for APNs on iOS).
  /// [provisional] asks for quiet delivery on iOS without showing a prompt.
  Future<NotificationPermissionState> requestPermission({
    bool provisional = false,
  });

  /// iOS: whether a push received in the foreground is shown by the system.
  /// Android never shows foreground pushes; the app shows them (see
  /// `PushService`).
  Future<void> setForegroundPresentation({required bool enabled});
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_core/core/notifications/models/notification_permission_state.dart';
import 'package:riverpod_core/core/notifications/models/push_message.dart';
import 'package:riverpod_core/core/notifications/push/push_backend.dart';
import 'package:riverpod_core/core/notifications/push/push_background_handler.dart';

/// [PushBackend] over `firebase_messaging`.
///
/// The token calls (`getToken`, `onTokenRefresh`, `deleteToken`) are the
/// deprecated ones on purpose: in firebase_messaging 17 their replacement,
/// `register()`/`onRegistered`, yields a Firebase Installation ID, a different
/// kind of identifier than the FCM token that servers send to. They are used
/// only in this file, so switching later is a one-file change.
class FirebasePushBackend implements PushBackend {
  /// [ensureFirebase] is `FirebaseBootstrap.ensureInitialized`: Firebase is
  /// started once for the whole app (D-042).
  FirebasePushBackend({required Future<bool> Function() ensureFirebase})
    : _ensureFirebase = ensureFirebase;

  final Future<bool> Function() _ensureFirebase;

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;

  @override
  Future<bool> initialize() async {
    try {
      if (!await _ensureFirebase()) return false;
      if (!await _fcm.isSupported()) return false;
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      return true;
    } on Object {
      // No google-services.json / GoogleService-Info.plist: push stays off.
      return false;
    }
  }

  static PushMessage _map(RemoteMessage message) {
    final notification = message.notification;
    final channel = notification?.android?.channelId ?? message.data['channel'];
    return PushMessage(
      id: message.messageId,
      title: notification?.title,
      body: notification?.body,
      imageUrl:
          notification?.android?.imageUrl ?? notification?.apple?.imageUrl,
      channelId: channel?.toString(),
      data: Map<String, Object?>.from(message.data),
    );
  }

  static NotificationPermissionState _mapStatus(AuthorizationStatus status) =>
      switch (status) {
        AuthorizationStatus.authorized => NotificationPermissionState.granted,
        AuthorizationStatus.provisional =>
          NotificationPermissionState.provisional,
        AuthorizationStatus.deniedPermanently =>
          NotificationPermissionState.permanentlyDenied,
        AuthorizationStatus.denied ||
        AuthorizationStatus.notDetermined => NotificationPermissionState.denied,
      };

  @override
  Stream<PushMessage> get onMessage => FirebaseMessaging.onMessage.map(_map);

  @override
  Stream<PushMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp.map(_map);

  @override
  Future<PushMessage?> initialMessage() async {
    final message = await _fcm.getInitialMessage();
    return message == null ? null : _map(message);
  }

  @override
  // ignore: deprecated_member_use
  Future<String?> token() => _fcm.getToken();

  @override
  // ignore: deprecated_member_use
  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  @override
  // ignore: deprecated_member_use
  Future<void> deleteToken() => _fcm.deleteToken();

  @override
  Future<void> subscribe(String topic) => _fcm.subscribeToTopic(topic);

  @override
  Future<void> unsubscribe(String topic) => _fcm.unsubscribeFromTopic(topic);

  @override
  Future<NotificationPermissionState> permission() async =>
      _mapStatus((await _fcm.getNotificationSettings()).authorizationStatus);

  @override
  Future<NotificationPermissionState> requestPermission({
    bool provisional = false,
  }) async => _mapStatus(
    (await _fcm.requestPermission(
      provisional: provisional,
    )).authorizationStatus,
  );

  @override
  Future<void> setForegroundPresentation({required bool enabled}) =>
      _fcm.setForegroundNotificationPresentationOptions(
        alert: enabled,
        badge: enabled,
        sound: enabled,
      );
}

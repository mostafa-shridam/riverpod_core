import 'dart:async';

import 'package:riverpod_core/core/device/device_info.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';
import 'package:riverpod_core/core/notifications/push/push_backend.dart';
import 'package:riverpod_core/core/notifications/registration/push_token_registrar.dart';
import 'package:riverpod_core/core/notifications/registration/push_token_registration.dart';

/// Keeps the backend's copy of the FCM token right: registers it when the
/// user is signed in and notifications are on, follows token refreshes and
/// removes it on logout. A failing registrar is logged and retried at the
/// next trigger (sign-in, refresh, settings change); it never breaks the app.
class PushTokenManager {
  PushTokenManager({
    required PushBackend push,
    required PushTokenRegistrar registrar,
    required Future<DeviceInfo> Function() device,
    required bool Function() isEnabled,
    required AppLogger logger,
  }) : _push = push,
       _registrar = registrar,
       _device = device,
       _isEnabled = isEnabled,
       _logger = logger;

  final PushBackend _push;
  final PushTokenRegistrar _registrar;
  final Future<DeviceInfo> Function() _device;

  /// Whether the user's master switch is on (read each time).
  final bool Function() _isEnabled;
  final AppLogger _logger;

  StreamSubscription<String>? _refreshes;
  bool _signedIn = false;
  String? _registered;

  /// The token last sent to the backend, or null.
  String? get registeredToken => _registered;

  /// Starts following token refreshes.
  void start() {
    _refreshes ??= _push.onTokenRefresh.listen(
      (_) => unawaited(_sync()),
      onError: (Object error) =>
          _logger.warning('Push token refresh failed', error: error),
    );
  }

  /// The user signed in: register the current token.
  Future<void> onSignedIn() {
    _signedIn = true;
    return _sync();
  }

  /// The master switch changed: register when turned on, unregister when off.
  Future<void> setEnabled({required bool enabled}) async {
    if (enabled) {
      await _sync();
    } else {
      await _unregister();
    }
  }

  /// The user is leaving: unregister on the server while the session still
  /// works, then drop the token so no push reaches the next user of this
  /// device. Call it BEFORE the logout wipe clears the credentials.
  Future<void> onLogout() async {
    _signedIn = false;
    await _unregister();
    try {
      await _push.deleteToken();
    } on Object catch (error) {
      _logger.warning('Could not delete the push token', error: error);
    }
  }

  Future<void> _sync() async {
    if (!_signedIn || !_isEnabled()) return;
    try {
      final token = await _push.token();
      if (token == null || token == _registered) return;
      await _registrar.register(
        PushTokenRegistration(
          token: token,
          device: await _device(),
          previousToken: _registered,
        ),
      );
      _registered = token;
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'Push token registration failed; it is retried later',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _unregister() async {
    final token = _registered;
    if (token == null) return;
    try {
      await _registrar.unregister(token);
    } on Object catch (error) {
      _logger.warning('Push token unregistration failed', error: error);
    }
    _registered = null;
  }

  Future<void> dispose() async {
    await _refreshes?.cancel();
    _refreshes = null;
  }
}

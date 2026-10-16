import 'package:riverpod_core/core/notifications/registration/push_token_registrar.dart';
import 'package:riverpod_core/core/notifications/registration/push_token_registration.dart';

/// Default registrar: does nothing, so a new app works without a backend.
class NoopPushTokenRegistrar implements PushTokenRegistrar {
  const NoopPushTokenRegistrar();

  @override
  Future<void> register(PushTokenRegistration registration) async {}

  @override
  Future<void> unregister(String token) async {}
}

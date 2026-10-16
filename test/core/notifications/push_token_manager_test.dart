import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/notifications/push/push_token_manager.dart';

import '../../helpers/fake_notification_backends.dart';

void main() {
  late FakePushBackend push;
  late FakePushTokenRegistrar registrar;
  late List<String> logs;
  late bool enabled;
  late PushTokenManager manager;

  setUp(() {
    push = FakePushBackend();
    registrar = FakePushTokenRegistrar();
    logs = [];
    enabled = true;
    manager = PushTokenManager(
      push: push,
      registrar: registrar,
      device: () async => testDevice,
      isEnabled: () => enabled,
      logger: recordingLogger(logs),
    )..start();
  });

  tearDown(() async {
    await manager.dispose();
  });

  test('nothing is registered before sign-in', () async {
    push.refreshes.add('token-2');
    await Future<void>.delayed(Duration.zero);

    expect(registrar.registrations, isEmpty);
  });

  test('sign-in registers the token with the device', () async {
    await manager.onSignedIn();

    expect(registrar.registrations, hasLength(1));
    expect(registrar.registrations.single.token, 'token-1');
    expect(registrar.registrations.single.device, testDevice);
    expect(registrar.registrations.single.previousToken, isNull);
    expect(manager.registeredToken, 'token-1');
  });

  test('the same token is not registered twice', () async {
    await manager.onSignedIn();
    await manager.onSignedIn();

    expect(registrar.registrations, hasLength(1));
  });

  test('a refresh registers the new token and names the old one', () async {
    await manager.onSignedIn();

    push.currentToken = 'token-2';
    push.refreshes.add('token-2');
    await Future<void>.delayed(Duration.zero);

    expect(registrar.registrations, hasLength(2));
    expect(registrar.registrations.last.token, 'token-2');
    expect(registrar.registrations.last.previousToken, 'token-1');
  });

  test('nothing is registered while notifications are off', () async {
    enabled = false;

    await manager.onSignedIn();

    expect(registrar.registrations, isEmpty);
  });

  test('turning notifications off unregisters, on registers again', () async {
    await manager.onSignedIn();

    enabled = false;
    await manager.setEnabled(enabled: false);
    expect(registrar.unregistered, ['token-1']);
    expect(manager.registeredToken, isNull);

    enabled = true;
    await manager.setEnabled(enabled: true);
    expect(registrar.registrations, hasLength(2));
  });

  test('logout unregisters, deletes the token and stops registering', () async {
    await manager.onSignedIn();

    await manager.onLogout();

    expect(registrar.unregistered, ['token-1']);
    expect(push.deleteTokenCalls, 1);

    push.currentToken = 'token-2';
    push.refreshes.add('token-2');
    await Future<void>.delayed(Duration.zero);
    expect(registrar.registrations, hasLength(1));
  });

  test('a failing registrar is logged, not thrown, and retried', () async {
    registrar.failWith = StateError('offline');

    await manager.onSignedIn();

    expect(registrar.registrations, isEmpty);
    expect(manager.registeredToken, isNull);
    expect(logs.single, startsWith('warning: Push token registration failed'));

    registrar.failWith = null;
    await manager.onSignedIn();
    expect(registrar.registrations, hasLength(1));
  });

  test('a failing unregister does not stop the logout', () async {
    await manager.onSignedIn();
    registrar.failWith = StateError('offline');

    await manager.onLogout();

    expect(push.deleteTokenCalls, 1);
    expect(manager.registeredToken, isNull);
  });
}

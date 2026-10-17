import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/config/log_level.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';
import 'package:riverpod_core/features/auth/data/models/auth_requests.dart';
import 'package:riverpod_core/features/auth/data/models/auth_session.dart';
import 'package:riverpod_core/features/auth/data/sources/auth_remote_source.dart';
import 'package:riverpod_core/features/auth/providers/forgot_password_controller.dart';
import 'package:riverpod_core/features/auth/providers/login_controller.dart';
import 'package:riverpod_core/features/auth/providers/register_controller.dart';

import '../../helpers/helpers.dart';

/// A source whose answer each test chooses.
class _FakeSource implements AuthRemoteSource {
  _FakeSource({this.error, this.session});

  final Object? error;
  final AuthSession? session;

  Future<T> _answer<T>(T Function() ok) async {
    if (error != null) throw error!;
    return ok();
  }

  @override
  Future<AuthSession> login(LoginRequest request) => _answer(() => session!);

  @override
  Future<AuthSession> register(RegisterRequest request) =>
      _answer(() => session!);

  @override
  Future<void> forgotPassword(String email) => _answer(() {});

  @override
  Future<void> logout() => _answer(() {});
}

const _config = AppConfig(
  flavor: Flavor.dev,
  appName: 'Test',
  apiBaseUrl: 'https://api.example.test',
  connectTimeout: Duration(seconds: 15),
  receiveTimeout: Duration(seconds: 30),
  logLevel: LogLevel.off,
  enableCrashReporting: false,
  enableAnalytics: false,
);

ProviderContainer _container(AuthRemoteSource source) {
  return createContainer(
    overrides: [
      // Sign-in now tags analytics/crash, which read the config.
      appConfigProvider.overrideWithValue(_config),
      authRemoteSourceProvider.overrideWithValue(source),
      secureStorageProvider.overrideWithValue(FakeSecureStorage()),
    ],
  );
}

void main() {
  group('LoginController', () {
    test('success signs the session in', () async {
      final session = AuthSession.fromJson({
        'tokens': {'accessToken': 'a', 'refreshToken': 'r'},
        'user': {'id': '1', 'email': 'a@b.co', 'name': 'A'},
      });
      final container = _container(_FakeSource(session: session));
      final sub = container.listen(loginControllerProvider, (_, _) {});
      addTearDown(sub.close);

      await container
          .read(loginControllerProvider.notifier)
          .submit(email: 'a@b.co', password: 'secret1');

      expect(container.read(loginControllerProvider).hasError, isFalse);
      expect(container.read(sessionControllerProvider), SessionStatus.signedIn);
    });

    test('a validation error is kept for the form fields', () async {
      final container = _container(
        _FakeSource(
          error: const ValidationException(
            fieldErrors: {
              'email': ['Taken'],
            },
          ),
        ),
      );
      final sub = container.listen(loginControllerProvider, (_, _) {});
      addTearDown(sub.close);

      await container
          .read(loginControllerProvider.notifier)
          .submit(email: 'a@b.co', password: 'secret1');

      final error = container.read(loginControllerProvider).error;
      expect(error, isA<ValidationException>());
      expect((error! as ValidationException).firstMessageFor('email'), 'Taken');
      expect(
        container.read(sessionControllerProvider),
        SessionStatus.unknown,
        reason: 'a failed login does not sign in',
      );
    });

    test('a network error is an AppException', () async {
      final container = _container(
        _FakeSource(error: const NetworkException()),
      );
      final sub = container.listen(loginControllerProvider, (_, _) {});
      addTearDown(sub.close);

      await container
          .read(loginControllerProvider.notifier)
          .submit(email: 'a@b.co', password: 'secret1');

      expect(
        container.read(loginControllerProvider).error,
        isA<NetworkException>(),
      );
    });
  });

  group('RegisterController and ForgotPasswordController', () {
    test('a failed registration keeps the error', () async {
      final container = _container(
        _FakeSource(error: const ServerException(statusCode: 500)),
      );
      final sub = container.listen(registerControllerProvider, (_, _) {});
      addTearDown(sub.close);

      await container
          .read(registerControllerProvider.notifier)
          .submit(name: 'A', email: 'a@b.co', password: 'secret1');

      expect(
        container.read(registerControllerProvider).error,
        isA<ServerException>(),
      );
    });

    test('a forgot-password request that succeeds has no error', () async {
      final container = _container(_FakeSource());
      final sub = container.listen(forgotPasswordControllerProvider, (_, _) {});
      addTearDown(sub.close);

      await container
          .read(forgotPasswordControllerProvider.notifier)
          .submit('a@b.co');

      expect(
        container.read(forgotPasswordControllerProvider).hasError,
        isFalse,
      );
    });
  });
}

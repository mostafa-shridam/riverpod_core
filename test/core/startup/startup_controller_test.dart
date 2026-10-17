import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/config/log_level.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/remote_config/remote_config.dart';
import 'package:riverpod_core/core/remote_config/remote_config_provider.dart';
import 'package:riverpod_core/core/remote_config/remote_config_source.dart';
import 'package:riverpod_core/core/startup/startup_controller.dart';
import 'package:riverpod_core/core/storage/cache/cache_store.dart';
import 'package:riverpod_core/core/storage/cache/cached_repository_helper.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';

import '../../helpers/helpers.dart';

/// Fails the first access-token read, then behaves normally.
class _FlakySecureStorage extends FakeSecureStorage {
  int reads = 0;

  @override
  Future<String?> readAccessToken() async {
    reads++;
    if (reads == 1) throw StateError('keychain unavailable');
    return super.readAccessToken();
  }
}

const _appConfig = AppConfig(
  flavor: Flavor.dev,
  appName: 'Test',
  apiBaseUrl: 'https://api.example.test',
  connectTimeout: Duration(seconds: 15),
  receiveTimeout: Duration(seconds: 30),
  logLevel: LogLevel.off,
  enableCrashReporting: false,
  enableAnalytics: false,
);

Future<ProviderContainer> _container({
  SecureStorage? secure,
  Duration minimum = Duration.zero,
  RemoteConfigSource? remote,
  Duration remoteTimeout = const Duration(seconds: 3),
}) async {
  final storage = await openTestStorage();
  final prefs = PrefsStorage(storage.settings);
  final cache = CacheStore(storage.cache);
  final container = createContainer(
    overrides: [
      appConfigProvider.overrideWithValue(_appConfig),
      secureStorageProvider.overrideWithValue(secure ?? FakeSecureStorage()),
      prefsStorageProvider.overrideWith((ref) => Future.value(prefs)),
      splashMinimumDisplayProvider.overrideWithValue(minimum),
      cacheStoreProvider.overrideWithValue(cache),
      remoteConfigSourceProvider.overrideWithValue(
        remote ?? const MockRemoteConfigSource(),
      ),
      splashRemoteConfigTimeoutProvider.overrideWithValue(remoteTimeout),
    ],
  );
  return container;
}

/// Never answers, like a server that hangs.
class _Hanging implements RemoteConfigSource {
  @override
  Future<CacheFetch<RemoteConfig>> fetch() =>
      Completer<CacheFetch<RemoteConfig>>().future;
}

/// Fails like an unreachable server.
class _Unreachable implements RemoteConfigSource {
  @override
  Future<CacheFetch<RemoteConfig>> fetch() async =>
      throw const NetworkException();
}

void main() {
  group('remote config is optional', () {
    test('an unreachable config never blocks startup', () async {
      final container = await _container(remote: _Unreachable());
      addTearDown(container.dispose);

      await container.read(startupControllerProvider.future);

      expect(container.read(startupReadyProvider), isTrue);
      expect(
        container.read(currentRemoteConfigProvider),
        RemoteConfig.defaults,
      );
    });

    test('a hanging config is cut off at the timeout', () async {
      final container = await _container(
        remote: _Hanging(),
        remoteTimeout: const Duration(milliseconds: 20),
      );
      addTearDown(container.dispose);

      await container.read(startupControllerProvider.future);

      expect(container.read(startupReadyProvider), isTrue);
    });
  });

  group('startup sequence', () {
    test('restores the session and reads settings, then is ready', () async {
      final container = await _container();
      addTearDown(container.dispose);
      expect(container.read(startupReadyProvider), isFalse);

      await container.read(startupControllerProvider.future);

      expect(container.read(startupReadyProvider), isTrue);
      expect(
        container.read(sessionControllerProvider),
        SessionStatus.signedOut,
        reason: 'no stored token, so the restore step ends signed out',
      );
    });

    test('holds for the minimum display time', () async {
      final container = await _container(
        minimum: const Duration(milliseconds: 120),
      );
      addTearDown(container.dispose);

      final watch = Stopwatch()..start();
      await container.read(startupControllerProvider.future);
      watch.stop();

      expect(
        watch.elapsed,
        greaterThanOrEqualTo(const Duration(milliseconds: 120)),
      );
    });

    test(
      'a failed step leaves the sequence in error, and retry recovers',
      () async {
        final container = await _container(secure: _FlakySecureStorage());
        addTearDown(container.dispose);

        await expectLater(
          container.read(startupControllerProvider.future),
          throwsA(isA<StateError>()),
        );
        expect(container.read(startupReadyProvider), isFalse);

        container.invalidate(startupControllerProvider);
        await container.read(startupControllerProvider.future);

        expect(container.read(startupReadyProvider), isTrue);
      },
    );
  });
}

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

/// A clock the test moves by hand.
class _Clock {
  _Clock(this.now);

  DateTime now;

  DateTime call() => now;
}

Future<ProviderContainer> _container({
  SecureStorage? secure,
  Duration minimum = Duration.zero,
  RemoteConfigSource? remote,
  Duration remoteTimeout = const Duration(seconds: 3),
  _Clock? clock,
}) async {
  final storage = await openTestStorage();
  final prefs = PrefsStorage(storage.settings);
  final cache = CacheStore(storage.cache);
  final time = clock ?? _Clock(DateTime(2026));
  final container = createContainer(
    overrides: [
      appConfigProvider.overrideWithValue(_appConfig),
      secureStorageProvider.overrideWithValue(secure ?? FakeSecureStorage()),
      prefsStorageProvider.overrideWith((ref) => Future.value(prefs)),
      startupClockProvider.overrideWithValue(time.call),
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

    test(
      'holds until the minimum display time has passed on the clock',
      () async {
        final clock = _Clock(DateTime(2026));
        final container = await _container(
          minimum: const Duration(milliseconds: 120),
          clock: clock,
        );
        addTearDown(container.dispose);

        var done = false;
        final sequence = container.read(startupControllerProvider.future);
        unawaited(sequence.then((_) => done = true));
        // The clock has not moved, so the splash must keep holding however long
        // the event loop runs.
        await Future<void>.delayed(const Duration(milliseconds: 60));
        expect(done, isFalse, reason: 'the clock has not reached the minimum');

        clock.now = clock.now.add(const Duration(milliseconds: 120));
        await sequence;

        expect(done, isTrue);
        expect(container.read(startupReadyProvider), isTrue);
      },
    );

    test('a clock already past the minimum does not wait', () async {
      final clock = _Clock(DateTime(2026));
      final container = await _container(
        minimum: const Duration(hours: 1),
        clock: clock,
      );
      addTearDown(container.dispose);

      // The deadline is taken when the sequence starts; the clock then passes it.
      final sequence = container.read(startupControllerProvider.future);
      clock.now = clock.now.add(const Duration(hours: 2));
      await sequence;

      expect(container.read(startupReadyProvider), isTrue);
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

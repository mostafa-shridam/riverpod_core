import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/security/app_lock_controller.dart';
import 'package:riverpod_core/core/security/biometric_service.dart';
import 'package:riverpod_core/core/security/secure_screen.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

import '../../helpers/helpers.dart';
import 'security_fakes.dart';

class _Harness {
  _Harness._(this.container, this.prefs, this.biometric, this.secure);

  final ProviderContainer container;
  final PrefsStorage prefs;
  final FakeBiometricBackend biometric;
  final FakeSecureScreenBackend secure;
  DateTime now = DateTime(2026, 1, 1, 12);

  AppLockController get controller =>
      container.read(appLockControllerProvider.notifier);
  AppLockState get state => container.read(appLockControllerProvider);

  static Future<_Harness> create({
    Map<String, Object> initialPrefs = const {},
    Duration timeout = const Duration(seconds: 30),
    FakeBiometricBackend? biometric,
    PrefsStorage? prefs,
  }) async {
    final storage = prefs ?? await fakePrefsStorage(initialPrefs);
    final fakeBiometric = biometric ?? FakeBiometricBackend();
    final fakeSecure = FakeSecureScreenBackend();
    late _Harness harness;
    final container = createContainer(
      overrides: [
        prefsStorageProvider.overrideWith((ref) => Future.value(storage)),
        biometricBackendProvider.overrideWithValue(fakeBiometric),
        secureScreenBackendProvider.overrideWithValue(fakeSecure),
        appLockTimeoutProvider.overrideWithValue(timeout),
        appLockClockProvider.overrideWithValue(() => harness.now),
      ],
    );
    harness = _Harness._(container, storage, fakeBiometric, fakeSecure);
    await container.read(prefsStorageProvider.future);
    return harness;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('persistence', () {
    test('starts off and unlocked', () async {
      final h = await _Harness.create();
      expect(h.state.enabled, isFalse);
      expect(h.state.locked, isFalse);
    });

    test('enabling needs one authentication and is stored', () async {
      final h = await _Harness.create();
      final result = await h.controller.setEnabled(enabled: true);

      expect(result, BiometricResult.success);
      expect(h.biometric.reasons, hasLength(1));
      expect(h.state.enabled, isTrue);
      expect(h.state.locked, isFalse, reason: 'the user just proved identity');
      expect(h.prefs.appLockEnabled, isTrue);
    });

    test('a refused enable changes nothing and returns the result', () async {
      for (final failure in [
        BiometricResult.cancelled,
        BiometricResult.failed,
        BiometricResult.lockedOut,
        BiometricResult.notAvailable,
      ]) {
        final h = await _Harness.create(
          biometric: FakeBiometricBackend(result: failure),
        );
        expect(await h.controller.setEnabled(enabled: true), failure);
        expect(h.state.enabled, isFalse);
        expect(h.prefs.appLockEnabled, isFalse);
      }
    });

    test('disabling is stored and needs no prompt', () async {
      final h = await _Harness.create(
        initialPrefs: {
          PrefKeys.appLock: ['1'],
        },
      );
      expect(h.state.enabled, isTrue);
      expect(
        await h.controller.setEnabled(enabled: false),
        BiometricResult.success,
      );
      expect(h.state.enabled, isFalse);
      expect(h.state.locked, isFalse);
      expect(h.prefs.appLockEnabled, isFalse);
      expect(h.biometric.reasons, isEmpty);
    });

    test('a new session starts locked when the flag is on', () async {
      final first = await _Harness.create();
      await first.controller.setEnabled(enabled: true);

      final second = await _Harness.create(prefs: first.prefs);
      expect(second.state.enabled, isTrue);
      expect(second.state.locked, isTrue);
    });

    test('the flag is a device setting that survives logout', () async {
      final h = await _Harness.create();
      await h.controller.setEnabled(enabled: true);
      await h.prefs.clearUserScoped();
      expect(h.prefs.appLockEnabled, isTrue);
    });
  });

  group('lock after the background timeout', () {
    // (seconds in the background, timeout seconds, expected locked)
    const matrix = <(int, int, bool)>[
      (5, 30, false),
      (29, 30, false),
      (30, 30, true),
      (31, 30, true),
      (600, 30, true),
      (0, 0, true),
      (1, 0, true),
      (59, 60, false),
      (60, 60, true),
    ];

    for (final (away, timeout, locked) in matrix) {
      test('away ${away}s with timeout ${timeout}s -> '
          '${locked ? 'locked' : 'unlocked'}', () async {
        final h = await _Harness.create(timeout: Duration(seconds: timeout));
        await h.controller.setEnabled(enabled: true);

        h.controller.onLifecycle(AppLifecycleState.paused);
        h.now = h.now.add(Duration(seconds: away));
        h.controller.onLifecycle(AppLifecycleState.resumed);

        expect(h.state.locked, locked);
        expect(h.state.obscured, isFalse);
      });
    }

    test('the content is hidden while away, even before the timeout', () async {
      final h = await _Harness.create();
      await h.controller.setEnabled(enabled: true);

      h.controller.onLifecycle(AppLifecycleState.inactive);
      expect(h.state.obscured, isTrue);
      expect(h.state.locked, isFalse);

      h.controller.onLifecycle(AppLifecycleState.resumed);
      expect(h.state.obscured, isFalse);
    });

    test('the timer starts at the first step away, not the last', () async {
      final h = await _Harness.create();
      await h.controller.setEnabled(enabled: true);

      h.controller.onLifecycle(AppLifecycleState.inactive);
      h.now = h.now.add(const Duration(seconds: 20));
      h.controller.onLifecycle(AppLifecycleState.hidden);
      h.now = h.now.add(const Duration(seconds: 20));
      h.controller.onLifecycle(AppLifecycleState.paused);
      h.controller.onLifecycle(AppLifecycleState.resumed);

      expect(h.state.locked, isTrue);
    });

    test('a lock stays until unlocked, however short the next trip', () async {
      final h = await _Harness.create(timeout: Duration.zero);
      await h.controller.setEnabled(enabled: true);
      h.controller.onLifecycle(AppLifecycleState.paused);
      h.controller.onLifecycle(AppLifecycleState.resumed);
      expect(h.state.locked, isTrue);

      h.controller.onLifecycle(AppLifecycleState.paused);
      h.controller.onLifecycle(AppLifecycleState.resumed);
      expect(h.state.locked, isTrue);
    });

    test('never locks when the setting is off', () async {
      final h = await _Harness.create(timeout: Duration.zero);
      h.controller.onLifecycle(AppLifecycleState.paused);
      h.now = h.now.add(const Duration(hours: 1));
      h.controller.onLifecycle(AppLifecycleState.resumed);
      expect(h.state.locked, isFalse);
      expect(h.state.obscured, isFalse);
    });
  });

  group('unlock', () {
    Future<_Harness> lockedHarness(BiometricResult result) async {
      final h = await _Harness.create(
        initialPrefs: {
          PrefKeys.appLock: ['1'],
        },
        biometric: FakeBiometricBackend(result: result),
      );
      expect(h.state.locked, isTrue);
      return h;
    }

    test('success clears the lock', () async {
      final h = await lockedHarness(BiometricResult.success);
      expect(await h.controller.unlock(), BiometricResult.success);
      expect(h.state.locked, isFalse);
      expect(h.state.unlocking, isFalse);
      expect(h.state.lastResult, isNull);
    });

    test('cancel, failure and lockout keep it locked, typed', () async {
      for (final result in [
        BiometricResult.cancelled,
        BiometricResult.failed,
        BiometricResult.lockedOut,
      ]) {
        final h = await lockedHarness(result);
        expect(await h.controller.unlock(), result);
        expect(h.state.locked, isTrue);
        expect(h.state.unlocking, isFalse);
        expect(h.state.lastResult, result);
      }
    });

    test('a retry after a cancel can succeed', () async {
      final h = await lockedHarness(BiometricResult.cancelled);
      await h.controller.unlock();
      h.biometric.result = BiometricResult.success;
      await h.controller.unlock();
      expect(h.state.locked, isFalse);
    });

    test('a device with no credentials turns the lock off', () async {
      final h = await lockedHarness(BiometricResult.notAvailable);
      expect(await h.controller.unlock(), BiometricResult.notAvailable);
      expect(h.state.enabled, isFalse);
      expect(h.state.locked, isFalse);
      expect(h.prefs.appLockEnabled, isFalse);
    });

    test('unlock while unlocked does not prompt', () async {
      final h = await _Harness.create();
      expect(await h.controller.unlock(), BiometricResult.success);
      expect(h.biometric.reasons, isEmpty);
    });
  });

  group('screenshot protection while the lock is on', () {
    test('holds the secure screen only while enabled', () async {
      final h = await _Harness.create();
      await h.controller.setEnabled(enabled: true);
      await Future<void>.delayed(Duration.zero);
      expect(h.secure.calls, [true]);

      await h.controller.setEnabled(enabled: false);
      await Future<void>.delayed(Duration.zero);
      expect(h.secure.calls, [true, false]);
    });
  });
}

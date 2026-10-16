import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/startup/startup_controller.dart';
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

Future<ProviderContainer> _container({
  SecureStorage? secure,
  Duration minimum = Duration.zero,
}) async {
  final prefs = await fakePrefsStorage();
  return createContainer(
    overrides: [
      secureStorageProvider.overrideWithValue(secure ?? FakeSecureStorage()),
      prefsStorageProvider.overrideWith((ref) => Future.value(prefs)),
      splashMinimumDisplayProvider.overrideWithValue(minimum),
    ],
  );
}

void main() {
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

import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_core/core/security/biometric_service.dart';

import 'security_fakes.dart';

class _MockLocalAuth extends Mock implements LocalAuthentication {}

void main() {
  group('mapLocalAuthCode', () {
    const expected = {
      LocalAuthExceptionCode.userCanceled: BiometricResult.cancelled,
      LocalAuthExceptionCode.systemCanceled: BiometricResult.cancelled,
      LocalAuthExceptionCode.timeout: BiometricResult.cancelled,
      LocalAuthExceptionCode.userRequestedFallback: BiometricResult.cancelled,
      LocalAuthExceptionCode.noCredentialsSet: BiometricResult.notAvailable,
      LocalAuthExceptionCode.noBiometricsEnrolled: BiometricResult.notAvailable,
      LocalAuthExceptionCode.noBiometricHardware: BiometricResult.notAvailable,
      LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
          BiometricResult.notAvailable,
      LocalAuthExceptionCode.temporaryLockout: BiometricResult.lockedOut,
      LocalAuthExceptionCode.biometricLockout: BiometricResult.lockedOut,
      LocalAuthExceptionCode.authInProgress: BiometricResult.failed,
      LocalAuthExceptionCode.uiUnavailable: BiometricResult.failed,
      LocalAuthExceptionCode.deviceError: BiometricResult.failed,
      LocalAuthExceptionCode.unknownError: BiometricResult.failed,
    };

    test('covers every code', () {
      expect(expected.keys.toSet(), LocalAuthExceptionCode.values.toSet());
    });

    for (final entry in expected.entries) {
      test('${entry.key.name} -> ${entry.value.name}', () {
        expect(mapLocalAuthCode(entry.key), entry.value);
      });
    }
  });

  group('LocalAuthBackend', () {
    late _MockLocalAuth auth;
    late LocalAuthBackend backend;

    setUp(() {
      auth = _MockLocalAuth();
      backend = LocalAuthBackend(auth);
    });

    void stubAuthenticate(Future<bool> Function() answer) {
      when(
        () => auth.authenticate(localizedReason: any(named: 'localizedReason')),
      ).thenAnswer((_) => answer());
    }

    test('true is success, false is failed', () async {
      stubAuthenticate(() async => true);
      expect(await backend.authenticate('r'), BiometricResult.success);
      stubAuthenticate(() async => false);
      expect(await backend.authenticate('r'), BiometricResult.failed);
    });

    test('a plugin exception becomes a typed result', () async {
      stubAuthenticate(
        () async => throw const LocalAuthException(
          code: LocalAuthExceptionCode.userCanceled,
        ),
      );
      expect(await backend.authenticate('r'), BiometricResult.cancelled);
    });

    test('an unexpected error is failed, never thrown', () async {
      stubAuthenticate(() async => throw StateError('boom'));
      expect(await backend.authenticate('r'), BiometricResult.failed);
    });

    test('isAvailable follows the device and survives errors', () async {
      when(() => auth.isDeviceSupported()).thenAnswer((_) async => true);
      expect(await backend.isAvailable(), isTrue);
      when(() => auth.isDeviceSupported()).thenThrow(StateError('boom'));
      expect(await backend.isAvailable(), isFalse);
    });
  });

  group('BiometricService', () {
    test('does not prompt when the device cannot authenticate', () async {
      final backend = FakeBiometricBackend(available: false);
      final result = await BiometricService(backend).authenticate('reason');
      expect(result, BiometricResult.notAvailable);
      expect(backend.reasons, isEmpty);
    });

    test('prompts and returns the backend result', () async {
      final backend = FakeBiometricBackend(result: BiometricResult.lockedOut);
      final result = await BiometricService(backend).authenticate('reason');
      expect(result, BiometricResult.lockedOut);
      expect(backend.reasons, hasLength(1));
    });
  });
}

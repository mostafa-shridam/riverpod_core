import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'biometric_service.g.dart';

/// Outcome of one authentication attempt. The UI never sees an exception.
enum BiometricResult {
  /// The user proved who they are.
  success,

  /// The user dismissed the prompt (or the system did).
  cancelled,

  /// The prompt ran but the check did not pass, or an unexpected error.
  failed,

  /// No biometrics and no device passcode: nothing to authenticate with.
  notAvailable,

  /// Too many failed attempts; try again later.
  lockedOut,
}

/// The platform side of biometrics. Tests implement it with a fake, so no
/// platform channel is needed.
abstract interface class BiometricBackend {
  /// True when the device can authenticate with biometrics or a passcode.
  Future<bool> isAvailable();

  /// Shows the system prompt. Biometrics first, device credential fallback.
  Future<BiometricResult> authenticate(String reason);
}

/// [BiometricResult] of a `local_auth` failure code.
BiometricResult mapLocalAuthCode(LocalAuthExceptionCode code) => switch (code) {
  LocalAuthExceptionCode.userCanceled ||
  LocalAuthExceptionCode.systemCanceled ||
  LocalAuthExceptionCode.timeout ||
  LocalAuthExceptionCode.userRequestedFallback => BiometricResult.cancelled,
  LocalAuthExceptionCode.noCredentialsSet ||
  LocalAuthExceptionCode.noBiometricsEnrolled ||
  LocalAuthExceptionCode.noBiometricHardware ||
  LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable =>
    BiometricResult.notAvailable,
  LocalAuthExceptionCode.temporaryLockout ||
  LocalAuthExceptionCode.biometricLockout => BiometricResult.lockedOut,
  _ => BiometricResult.failed,
};

/// [BiometricBackend] over `local_auth`. The only file importing the plugin.
class LocalAuthBackend implements BiometricBackend {
  LocalAuthBackend([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } on Object {
      return false;
    }
  }

  @override
  Future<BiometricResult> authenticate(String reason) async {
    try {
      final ok = await _auth.authenticate(localizedReason: reason);
      return ok ? BiometricResult.success : BiometricResult.failed;
    } on LocalAuthException catch (e) {
      return mapLocalAuthCode(e.code);
    } on Object {
      return BiometricResult.failed;
    }
  }
}

/// Asks the platform to check the user. One place, typed results.
class BiometricService {
  const BiometricService(this._backend);

  final BiometricBackend _backend;

  /// True when biometrics or a device passcode can be used.
  Future<bool> isAvailable() => _backend.isAvailable();

  /// Shows the prompt with the text of [reasonKey] (a `LocaleKeys` value).
  /// Returns [BiometricResult.notAvailable] without prompting when the device
  /// cannot authenticate.
  Future<BiometricResult> authenticate(String reasonKey) async {
    if (!await _backend.isAvailable()) return BiometricResult.notAvailable;
    return _backend.authenticate(reasonKey.tr());
  }
}

/// Backend seam: override in tests with a fake.
@Riverpod(keepAlive: true)
BiometricBackend biometricBackend(Ref ref) => LocalAuthBackend();

/// The one [BiometricService] of the app.
@Riverpod(keepAlive: true)
BiometricService biometricService(Ref ref) =>
    BiometricService(ref.watch(biometricBackendProvider));

/// Whether this device can use app lock. Read by the settings page.
@riverpod
Future<bool> biometricAvailable(Ref ref) =>
    ref.watch(biometricServiceProvider).isAvailable();

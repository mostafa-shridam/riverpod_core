import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/security/biometric_service.dart';
import 'package:riverpod_core/core/security/secure_screen.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

import '../../helpers/fake_connectivity.dart';
import '../../helpers/fake_prefs_storage.dart';

/// [BiometricBackend] with scripted answers. Records every prompt.
class FakeBiometricBackend implements BiometricBackend {
  FakeBiometricBackend({
    this.available = true,
    this.result = BiometricResult.success,
  });

  bool available;
  BiometricResult result;
  final List<String> reasons = [];

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<BiometricResult> authenticate(String reason) async {
    reasons.add(reason);
    return result;
  }
}

/// [SecureScreenBackend] that records every switch.
class FakeSecureScreenBackend implements SecureScreenBackend {
  final List<bool> calls = [];

  @override
  Future<void> setSecure({required bool secure}) async => calls.add(secure);
}

/// Overrides for pages and the overlay: in-memory prefs, fake native
/// backends and a fake online connectivity.
Future<List<Override>> securityOverrides(
  WidgetTester tester, {
  FakeBiometricBackend? biometric,
  Map<String, Object> prefs = const {},
}) async {
  final storage = await tester.runAsync(() => fakePrefsStorage(prefs));
  return [
    prefsStorageProvider.overrideWith((ref) => Future.value(storage)),
    biometricBackendProvider.overrideWithValue(
      biometric ?? FakeBiometricBackend(),
    ),
    secureScreenBackendProvider.overrideWithValue(FakeSecureScreenBackend()),
    FakeConnectivity().providerOverride,
  ];
}

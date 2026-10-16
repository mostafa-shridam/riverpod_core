// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Backend seam: override in tests with a fake.

@ProviderFor(secureScreenBackend)
final secureScreenBackendProvider = SecureScreenBackendProvider._();

/// Backend seam: override in tests with a fake.

final class SecureScreenBackendProvider
    extends
        $FunctionalProvider<
          SecureScreenBackend,
          SecureScreenBackend,
          SecureScreenBackend
        >
    with $Provider<SecureScreenBackend> {
  /// Backend seam: override in tests with a fake.
  SecureScreenBackendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureScreenBackendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureScreenBackendHash();

  @$internal
  @override
  $ProviderElement<SecureScreenBackend> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SecureScreenBackend create(Ref ref) {
    return secureScreenBackend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecureScreenBackend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecureScreenBackend>(value),
    );
  }
}

String _$secureScreenBackendHash() =>
    r'e23ab75f3d924013c0cb2715caf2bccf54e9890c';

/// The one [SecureScreenGate] of the app.

@ProviderFor(secureScreenGate)
final secureScreenGateProvider = SecureScreenGateProvider._();

/// The one [SecureScreenGate] of the app.

final class SecureScreenGateProvider
    extends
        $FunctionalProvider<
          SecureScreenGate,
          SecureScreenGate,
          SecureScreenGate
        >
    with $Provider<SecureScreenGate> {
  /// The one [SecureScreenGate] of the app.
  SecureScreenGateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureScreenGateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureScreenGateHash();

  @$internal
  @override
  $ProviderElement<SecureScreenGate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SecureScreenGate create(Ref ref) {
    return secureScreenGate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecureScreenGate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecureScreenGate>(value),
    );
  }
}

String _$secureScreenGateHash() => r'cc4fb95dda366f4fb1cbf8028b435e9eed64bec0';

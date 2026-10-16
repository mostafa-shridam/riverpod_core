// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biometric_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Backend seam: override in tests with a fake.

@ProviderFor(biometricBackend)
final biometricBackendProvider = BiometricBackendProvider._();

/// Backend seam: override in tests with a fake.

final class BiometricBackendProvider
    extends
        $FunctionalProvider<
          BiometricBackend,
          BiometricBackend,
          BiometricBackend
        >
    with $Provider<BiometricBackend> {
  /// Backend seam: override in tests with a fake.
  BiometricBackendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biometricBackendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biometricBackendHash();

  @$internal
  @override
  $ProviderElement<BiometricBackend> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BiometricBackend create(Ref ref) {
    return biometricBackend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiometricBackend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiometricBackend>(value),
    );
  }
}

String _$biometricBackendHash() => r'327e4869486b0a59f2eb0d89b4fd177079cc27c5';

/// The one [BiometricService] of the app.

@ProviderFor(biometricService)
final biometricServiceProvider = BiometricServiceProvider._();

/// The one [BiometricService] of the app.

final class BiometricServiceProvider
    extends
        $FunctionalProvider<
          BiometricService,
          BiometricService,
          BiometricService
        >
    with $Provider<BiometricService> {
  /// The one [BiometricService] of the app.
  BiometricServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biometricServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biometricServiceHash();

  @$internal
  @override
  $ProviderElement<BiometricService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BiometricService create(Ref ref) {
    return biometricService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiometricService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiometricService>(value),
    );
  }
}

String _$biometricServiceHash() => r'd90f1539eebaa64a160a2163e7373306becadb8a';

/// Whether this device can use app lock. Read by the settings page.

@ProviderFor(biometricAvailable)
final biometricAvailableProvider = BiometricAvailableProvider._();

/// Whether this device can use app lock. Read by the settings page.

final class BiometricAvailableProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether this device can use app lock. Read by the settings page.
  BiometricAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biometricAvailableProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biometricAvailableHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return biometricAvailable(ref);
  }
}

String _$biometricAvailableHash() =>
    r'c1a0ebc3404d24779856ec89dc9017dccac3cb25';

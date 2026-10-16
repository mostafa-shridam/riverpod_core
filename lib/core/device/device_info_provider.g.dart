// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Platform seam: override in tests with a fake.

@ProviderFor(deviceInfoSource)
final deviceInfoSourceProvider = DeviceInfoSourceProvider._();

/// Platform seam: override in tests with a fake.

final class DeviceInfoSourceProvider
    extends
        $FunctionalProvider<
          DeviceInfoSource,
          DeviceInfoSource,
          DeviceInfoSource
        >
    with $Provider<DeviceInfoSource> {
  /// Platform seam: override in tests with a fake.
  DeviceInfoSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceInfoSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceInfoSourceHash();

  @$internal
  @override
  $ProviderElement<DeviceInfoSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceInfoSource create(Ref ref) {
    return deviceInfoSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceInfoSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceInfoSource>(value),
    );
  }
}

String _$deviceInfoSourceHash() => r'fec686bc669816f5865be77d802a6b3102569e2a';

/// Source of randomness for the install id: override in tests.

@ProviderFor(installationIdRandom)
final installationIdRandomProvider = InstallationIdRandomProvider._();

/// Source of randomness for the install id: override in tests.

final class InstallationIdRandomProvider
    extends $FunctionalProvider<Random, Random, Random>
    with $Provider<Random> {
  /// Source of randomness for the install id: override in tests.
  InstallationIdRandomProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'installationIdRandomProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$installationIdRandomHash();

  @$internal
  @override
  $ProviderElement<Random> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Random create(Ref ref) {
    return installationIdRandom(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Random value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Random>(value),
    );
  }
}

String _$installationIdRandomHash() =>
    r'aa098dca0c3bd14890256736ab7b84de3eec89ed';

/// The device facts the app may send to its backend (for example when
/// registering a push token).

@ProviderFor(deviceInfo)
final deviceInfoProvider = DeviceInfoProvider._();

/// The device facts the app may send to its backend (for example when
/// registering a push token).

final class DeviceInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<DeviceInfo>,
          DeviceInfo,
          FutureOr<DeviceInfo>
        >
    with $FutureModifier<DeviceInfo>, $FutureProvider<DeviceInfo> {
  /// The device facts the app may send to its backend (for example when
  /// registering a push token).
  DeviceInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceInfoHash();

  @$internal
  @override
  $FutureProviderElement<DeviceInfo> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DeviceInfo> create(Ref ref) {
    return deviceInfo(ref);
  }
}

String _$deviceInfoHash() => r'd37a68db0badd318d624c9cfc1c3a09e1889a2aa';

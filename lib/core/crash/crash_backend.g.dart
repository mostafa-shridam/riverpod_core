// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crash_backend.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Platform seam for Crashlytics: override in tests.

@ProviderFor(crashBackend)
final crashBackendProvider = CrashBackendProvider._();

/// Platform seam for Crashlytics: override in tests.

final class CrashBackendProvider
    extends $FunctionalProvider<CrashBackend, CrashBackend, CrashBackend>
    with $Provider<CrashBackend> {
  /// Platform seam for Crashlytics: override in tests.
  CrashBackendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crashBackendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crashBackendHash();

  @$internal
  @override
  $ProviderElement<CrashBackend> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CrashBackend create(Ref ref) {
    return crashBackend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrashBackend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrashBackend>(value),
    );
  }
}

String _$crashBackendHash() => r'5ef20c63889c29cc3e90c30d43cdd6cc26bc2b56';

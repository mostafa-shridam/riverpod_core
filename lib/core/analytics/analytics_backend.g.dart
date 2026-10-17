// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_backend.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Platform seam for Firebase Analytics: override in tests.

@ProviderFor(analyticsBackend)
final analyticsBackendProvider = AnalyticsBackendProvider._();

/// Platform seam for Firebase Analytics: override in tests.

final class AnalyticsBackendProvider
    extends
        $FunctionalProvider<
          AnalyticsBackend,
          AnalyticsBackend,
          AnalyticsBackend
        >
    with $Provider<AnalyticsBackend> {
  /// Platform seam for Firebase Analytics: override in tests.
  AnalyticsBackendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsBackendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsBackendHash();

  @$internal
  @override
  $ProviderElement<AnalyticsBackend> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnalyticsBackend create(Ref ref) {
    return analyticsBackend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsBackend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsBackend>(value),
    );
  }
}

String _$analyticsBackendHash() => r'f16e7eda991b14828ed1ff96176e14554051b6b8';

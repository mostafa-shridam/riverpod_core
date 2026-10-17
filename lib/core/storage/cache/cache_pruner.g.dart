// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_pruner.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The pruner for the whole app, on the one [CacheStore].

@ProviderFor(cachePruner)
final cachePrunerProvider = CachePrunerProvider._();

/// The pruner for the whole app, on the one [CacheStore].

final class CachePrunerProvider
    extends $FunctionalProvider<CachePruner, CachePruner, CachePruner>
    with $Provider<CachePruner> {
  /// The pruner for the whole app, on the one [CacheStore].
  CachePrunerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cachePrunerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cachePrunerHash();

  @$internal
  @override
  $ProviderElement<CachePruner> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CachePruner create(Ref ref) {
    return cachePruner(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CachePruner value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CachePruner>(value),
    );
  }
}

String _$cachePrunerHash() => r'b5aab0caa1fd5cee3fc3845df2ff471e38f81aa4';

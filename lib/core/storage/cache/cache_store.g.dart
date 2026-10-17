// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The cache store for the whole app, on the box bootstrap opened.

@ProviderFor(cacheStore)
final cacheStoreProvider = CacheStoreProvider._();

/// The cache store for the whole app, on the box bootstrap opened.

final class CacheStoreProvider
    extends $FunctionalProvider<CacheStore, CacheStore, CacheStore>
    with $Provider<CacheStore> {
  /// The cache store for the whole app, on the box bootstrap opened.
  CacheStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cacheStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cacheStoreHash();

  @$internal
  @override
  $ProviderElement<CacheStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CacheStore create(Ref ref) {
    return cacheStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CacheStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CacheStore>(value),
    );
  }
}

String _$cacheStoreHash() => r'aa4395286d62c2959807cc3c475120960c7a3f84';

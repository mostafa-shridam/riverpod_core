// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_repository_helper.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The helper for the whole app, backed by the one [CacheStore].

@ProviderFor(cachedRepositoryHelper)
final cachedRepositoryHelperProvider = CachedRepositoryHelperProvider._();

/// The helper for the whole app, backed by the one [CacheStore].

final class CachedRepositoryHelperProvider
    extends
        $FunctionalProvider<
          CachedRepositoryHelper,
          CachedRepositoryHelper,
          CachedRepositoryHelper
        >
    with $Provider<CachedRepositoryHelper> {
  /// The helper for the whole app, backed by the one [CacheStore].
  CachedRepositoryHelperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cachedRepositoryHelperProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cachedRepositoryHelperHash();

  @$internal
  @override
  $ProviderElement<CachedRepositoryHelper> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CachedRepositoryHelper create(Ref ref) {
    return cachedRepositoryHelper(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CachedRepositoryHelper value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CachedRepositoryHelper>(value),
    );
  }
}

String _$cachedRepositoryHelperHash() =>
    r'7653190152952bb2fe73cd0ced48baa58bb024c2';

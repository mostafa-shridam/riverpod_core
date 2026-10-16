// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_repository_helper.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The helper for the whole app, backed by the one [AppDatabase].

@ProviderFor(cachedRepositoryHelper)
final cachedRepositoryHelperProvider = CachedRepositoryHelperProvider._();

/// The helper for the whole app, backed by the one [AppDatabase].

final class CachedRepositoryHelperProvider
    extends
        $FunctionalProvider<
          CachedRepositoryHelper,
          CachedRepositoryHelper,
          CachedRepositoryHelper
        >
    with $Provider<CachedRepositoryHelper> {
  /// The helper for the whole app, backed by the one [AppDatabase].
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
    r'4a24ed2a2045efcca0a3265fc03b34ffd446582e';

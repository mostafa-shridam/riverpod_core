// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_videos_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Ids of the favorite videos, persisted through the repository (prefs).

@ProviderFor(FavoriteVideosController)
final favoriteVideosControllerProvider = FavoriteVideosControllerProvider._();

/// Ids of the favorite videos, persisted through the repository (prefs).
final class FavoriteVideosControllerProvider
    extends $AsyncNotifierProvider<FavoriteVideosController, Set<String>> {
  /// Ids of the favorite videos, persisted through the repository (prefs).
  FavoriteVideosControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteVideosControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteVideosControllerHash();

  @$internal
  @override
  FavoriteVideosController create() => FavoriteVideosController();
}

String _$favoriteVideosControllerHash() =>
    r'8c7649b70eb700c830d5c182ecbda606544eec3f';

/// Ids of the favorite videos, persisted through the repository (prefs).

abstract class _$FavoriteVideosController extends $AsyncNotifier<Set<String>> {
  FutureOr<Set<String>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Set<String>>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<String>>, Set<String>>,
              AsyncValue<Set<String>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

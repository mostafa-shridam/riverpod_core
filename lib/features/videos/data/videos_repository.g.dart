// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'videos_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The source the repository reads from: mock or real, decided by
/// [videosUseMockSource] in this one place.

@ProviderFor(videosSource)
final videosSourceProvider = VideosSourceProvider._();

/// The source the repository reads from: mock or real, decided by
/// [videosUseMockSource] in this one place.

final class VideosSourceProvider
    extends
        $FunctionalProvider<
          VideosRemoteSource,
          VideosRemoteSource,
          VideosRemoteSource
        >
    with $Provider<VideosRemoteSource> {
  /// The source the repository reads from: mock or real, decided by
  /// [videosUseMockSource] in this one place.
  VideosSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'videosSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$videosSourceHash();

  @$internal
  @override
  $ProviderElement<VideosRemoteSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VideosRemoteSource create(Ref ref) {
    return videosSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VideosRemoteSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VideosRemoteSource>(value),
    );
  }
}

String _$videosSourceHash() => r'0e0201064b5ee5a218d8de1721e55ce2e72bc3be';

@ProviderFor(videosRepository)
final videosRepositoryProvider = VideosRepositoryProvider._();

final class VideosRepositoryProvider
    extends
        $FunctionalProvider<
          VideosRepository,
          VideosRepository,
          VideosRepository
        >
    with $Provider<VideosRepository> {
  VideosRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'videosRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$videosRepositoryHash();

  @$internal
  @override
  $ProviderElement<VideosRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VideosRepository create(Ref ref) {
    return videosRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VideosRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VideosRepository>(value),
    );
  }
}

String _$videosRepositoryHash() => r'fa0f4ef4492c04beeb49aa823f640078cfdbb887';

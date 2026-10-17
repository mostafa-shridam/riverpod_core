// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_video_backend.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The playback engine the video pages use. Override with a fake in tests
/// and the integration flow; the default is `video_player`.

@ProviderFor(videoBackendFactory)
final videoBackendFactoryProvider = VideoBackendFactoryProvider._();

/// The playback engine the video pages use. Override with a fake in tests
/// and the integration flow; the default is `video_player`.

final class VideoBackendFactoryProvider
    extends
        $FunctionalProvider<
          AppVideoBackendFactory,
          AppVideoBackendFactory,
          AppVideoBackendFactory
        >
    with $Provider<AppVideoBackendFactory> {
  /// The playback engine the video pages use. Override with a fake in tests
  /// and the integration flow; the default is `video_player`.
  VideoBackendFactoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'videoBackendFactoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$videoBackendFactoryHash();

  @$internal
  @override
  $ProviderElement<AppVideoBackendFactory> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppVideoBackendFactory create(Ref ref) {
    return videoBackendFactory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppVideoBackendFactory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppVideoBackendFactory>(value),
    );
  }
}

String _$videoBackendFactoryHash() =>
    r'8fce30a620b5943ceaff8c6a4584aff7338ff6fc';

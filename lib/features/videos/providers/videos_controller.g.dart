// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'videos_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State and actions of the videos list page.

@ProviderFor(VideosController)
final videosControllerProvider = VideosControllerProvider._();

/// State and actions of the videos list page.
final class VideosControllerProvider
    extends $AsyncNotifierProvider<VideosController, VideosState> {
  /// State and actions of the videos list page.
  VideosControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'videosControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$videosControllerHash();

  @$internal
  @override
  VideosController create() => VideosController();
}

String _$videosControllerHash() => r'45c83c5a80c158b1dae6cf01d7be78f5d8ad4a09';

/// State and actions of the videos list page.

abstract class _$VideosController extends $AsyncNotifier<VideosState> {
  FutureOr<VideosState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<VideosState>, VideosState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<VideosState>, VideosState>,
              AsyncValue<VideosState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

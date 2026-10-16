// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_detail_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The video of the detail page: the one with [id], or, when [customUrl] is
/// set, a video built from that link.

@ProviderFor(videoDetail)
final videoDetailProvider = VideoDetailFamily._();

/// The video of the detail page: the one with [id], or, when [customUrl] is
/// set, a video built from that link.

final class VideoDetailProvider
    extends $FunctionalProvider<AsyncValue<Video>, Video, FutureOr<Video>>
    with $FutureModifier<Video>, $FutureProvider<Video> {
  /// The video of the detail page: the one with [id], or, when [customUrl] is
  /// set, a video built from that link.
  VideoDetailProvider._({
    required VideoDetailFamily super.from,
    required (String, {String? customUrl}) super.argument,
  }) : super(
         retry: null,
         name: r'videoDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$videoDetailHash();

  @override
  String toString() {
    return r'videoDetailProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Video> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Video> create(Ref ref) {
    final argument = this.argument as (String, {String? customUrl});
    return videoDetail(ref, argument.$1, customUrl: argument.customUrl);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$videoDetailHash() => r'ca2e6e880d961cb9055d15721365a85a1ff4a9dc';

/// The video of the detail page: the one with [id], or, when [customUrl] is
/// set, a video built from that link.

final class VideoDetailFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Video>,
          (String, {String? customUrl})
        > {
  VideoDetailFamily._()
    : super(
        retry: null,
        name: r'videoDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The video of the detail page: the one with [id], or, when [customUrl] is
  /// set, a video built from that link.

  VideoDetailProvider call(String id, {String? customUrl}) =>
      VideoDetailProvider._(argument: (id, customUrl: customUrl), from: this);

  @override
  String toString() => r'videoDetailProvider';
}

/// Videos suggested next to the video [id]. Loaded apart from the video, so a
/// failure here only hides this section (the `partial` state).

@ProviderFor(relatedVideos)
final relatedVideosProvider = RelatedVideosFamily._();

/// Videos suggested next to the video [id]. Loaded apart from the video, so a
/// failure here only hides this section (the `partial` state).

final class RelatedVideosProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Video>>,
          List<Video>,
          FutureOr<List<Video>>
        >
    with $FutureModifier<List<Video>>, $FutureProvider<List<Video>> {
  /// Videos suggested next to the video [id]. Loaded apart from the video, so a
  /// failure here only hides this section (the `partial` state).
  RelatedVideosProvider._({
    required RelatedVideosFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'relatedVideosProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$relatedVideosHash();

  @override
  String toString() {
    return r'relatedVideosProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Video>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Video>> create(Ref ref) {
    final argument = this.argument as String;
    return relatedVideos(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RelatedVideosProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$relatedVideosHash() => r'f20169405101155c6a58bb2a5ac99a5b490adc6d';

/// Videos suggested next to the video [id]. Loaded apart from the video, so a
/// failure here only hides this section (the `partial` state).

final class RelatedVideosFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Video>>, String> {
  RelatedVideosFamily._()
    : super(
        retry: null,
        name: r'relatedVideosProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Videos suggested next to the video [id]. Loaded apart from the video, so a
  /// failure here only hides this section (the `partial` state).

  RelatedVideosProvider call(String id) =>
      RelatedVideosProvider._(argument: id, from: this);

  @override
  String toString() => r'relatedVideosProvider';
}

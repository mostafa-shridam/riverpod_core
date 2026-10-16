import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_core/features/videos/data/models/video.dart';

part 'video_feed.freezed.dart';
part 'video_feed.g.dart';

/// The list response: the videos that loaded, and whether some part of the
/// feed failed on the server (the `partial` data state).
@freezed
abstract class VideoFeed with _$VideoFeed {
  const factory VideoFeed({
    @JsonKey(name: 'items') required List<Video> videos,
    @JsonKey(name: 'partial') @Default(false) bool hasPartialError,
  }) = _VideoFeed;

  factory VideoFeed.fromJson(Map<String, dynamic> json) =>
      _$VideoFeedFromJson(json);
}

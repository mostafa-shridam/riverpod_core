import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_core/features/videos/data/models/video.dart';

part 'videos_state.freezed.dart';

/// The loaded list plus the search text. Two dimensions of state, so it is a
/// freezed class and not a bare `AsyncValue<List<Video>>`.
@freezed
abstract class VideosState with _$VideosState {
  const factory VideosState({
    required List<Video> videos,
    required DateTime loadedAt,
    @Default('') String query,
    @Default(false) bool hasPartialError,
  }) = _VideosState;

  const VideosState._();

  /// Videos whose title or description contains [query] (case-insensitive).
  List<Video> get visible {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return videos;
    return videos
        .where(
          (v) =>
              v.title.toLowerCase().contains(needle) ||
              v.description.toLowerCase().contains(needle),
        )
        .toList();
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/features/videos/data/models/video.dart';
import 'package:riverpod_core/features/videos/data/videos_repository.dart';

part 'video_detail_providers.g.dart';

/// The video of the detail page: the one with [id], or, when [customUrl] is
/// set, a video built from that link.
@riverpod
Future<Video> videoDetail(Ref ref, String id, {String? customUrl}) async {
  final repository = ref.watch(videosRepositoryProvider);
  if (customUrl != null) return repository.customVideo(customUrl);
  return repository.fetchVideo(id);
}

/// Videos suggested next to the video [id]. Loaded apart from the video, so a
/// failure here only hides this section (the `partial` state).
@riverpod
Future<List<Video>> relatedVideos(Ref ref, String id) {
  return ref.watch(videosRepositoryProvider).fetchRelated(id);
}

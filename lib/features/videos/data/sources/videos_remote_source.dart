import 'package:dio/dio.dart';
import 'package:riverpod_core/features/videos/data/models/video.dart';
import 'package:riverpod_core/features/videos/data/models/video_feed.dart';

/// Path of the videos collection, relative to `AppConfig.apiBaseUrl`. The one
/// place to change when the backend differs.
const videosEndpoint = '/videos';

/// Real backend source on the shared `Dio` (NETWORKING.md). It throws
/// `DioException`; the repository maps it to an `AppException`.
class VideosRemoteSource {
  VideosRemoteSource(this._dio);

  final Dio _dio;

  Future<VideoFeed> fetchVideos() async {
    final response = await _dio.get<Map<String, dynamic>>(videosEndpoint);
    return VideoFeed.fromJson(response.data ?? const {'items': <Object>[]});
  }

  Future<Video> fetchVideo(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$videosEndpoint/$id',
    );
    return Video.fromJson(response.data!);
  }
}

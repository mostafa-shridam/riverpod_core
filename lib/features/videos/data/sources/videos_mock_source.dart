import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/features/videos/data/models/video.dart';
import 'package:riverpod_core/features/videos/data/models/video_feed.dart';
import 'package:riverpod_core/features/videos/data/sources/mock_scenario.dart';
import 'package:riverpod_core/features/videos/data/sources/sample_videos.dart';
import 'package:riverpod_core/features/videos/data/sources/videos_remote_source.dart';

/// Answers from `sampleVideos` without a backend. It implements the remote
/// source's interface, so swapping it for the real one is one flag (see
/// `videosUseMockSource`). [scenario] can change at any time.
class VideosMockSource implements VideosRemoteSource {
  VideosMockSource({
    this.scenario = MockScenario.success,
    this.latency = const Duration(milliseconds: 600),
    this.slowLatency = const Duration(seconds: 5),
    this.videos = sampleVideos,
  });

  MockScenario scenario;

  /// Delay of every normal answer.
  final Duration latency;

  /// Delay used by [MockScenario.slow].
  final Duration slowLatency;
  final List<Video> videos;

  Future<void> _answerDelay() => Future<void>.delayed(
    scenario == MockScenario.slow ? slowLatency : latency,
  );

  @override
  Future<VideoFeed> fetchVideos() async {
    await _answerDelay();
    return switch (scenario) {
      MockScenario.empty => const VideoFeed(videos: []),
      MockScenario.error => throw const ServerException(statusCode: 500),
      MockScenario.offline => throw const NetworkException(),
      MockScenario.partial => VideoFeed(
        videos: videos.take((videos.length / 2).ceil()).toList(),
        hasPartialError: true,
      ),
      MockScenario.success || MockScenario.slow => VideoFeed(videos: videos),
    };
  }

  @override
  Future<Video> fetchVideo(String id) async {
    await _answerDelay();
    return switch (scenario) {
      MockScenario.error => throw const ServerException(statusCode: 500),
      MockScenario.offline => throw const NetworkException(),
      _ => videos.firstWhere(
        (video) => video.id == id,
        orElse: () => throw const NotFoundException(),
      ),
    };
  }
}

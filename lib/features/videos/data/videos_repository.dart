import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/errors/error_mapper.dart';
import 'package:riverpod_core/core/network/dio_client.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/features/videos/data/models/video.dart';
import 'package:riverpod_core/features/videos/data/models/video_feed.dart';
import 'package:riverpod_core/features/videos/data/sources/mock_scenario.dart';
import 'package:riverpod_core/features/videos/data/sources/videos_mock_source.dart';
import 'package:riverpod_core/features/videos/data/sources/videos_remote_source.dart';

part 'videos_repository.g.dart';

/// THE switch between demo data and the real backend. `true` serves
/// `sampleVideos` from [VideosMockSource]; set `false` to call
/// [VideosRemoteSource] on [videosEndpoint]. Tests override
/// [videosSourceProvider] instead of touching this.
const videosUseMockSource = true;

/// Prefs key of the favorite video ids. Under `user.` so logout clears it.
const videoFavoritesKey = 'user.videos.favorites';

/// Id of the synthetic video built from a link the user typed.
const customVideoId = 'custom';

/// Videos for the list and detail pages. Returns models or throws an
/// [AppException]; JSON and `DioException` never leave this class.
class VideosRepository {
  VideosRepository(this._source, this._prefs);

  final VideosRemoteSource _source;
  final Future<PrefsStorage> _prefs;

  /// True when the source is the mock, so [simulate] has an effect.
  bool get supportsSimulation => _source is VideosMockSource;

  /// The active mock scenario (`success` when the source is the real one).
  MockScenario get scenario {
    final source = _source;
    return source is VideosMockSource ? source.scenario : MockScenario.success;
  }

  /// Switches the mock scenario. Ignored by the real source.
  void simulate(MockScenario scenario) {
    final source = _source;
    if (source is VideosMockSource) source.scenario = scenario;
  }

  /// The ONE read of the list (the controller and related videos use only
  /// this). D-038 wants it cache-first (cached list first, then a background
  /// revalidate that does not re-emit unchanged data): C-44 switches this
  /// method to the shared cache helper without touching any caller.
  Future<VideoFeed> fetchFeed() => _guard(_source.fetchVideos);

  Future<Video> fetchVideo(String id) => _guard(() => _source.fetchVideo(id));

  /// Up to [limit] other videos to suggest next to the video [id].
  Future<List<Video>> fetchRelated(String id, {int limit = 4}) async {
    final feed = await fetchFeed();
    return feed.videos.where((v) => v.id != id).take(limit).toList();
  }

  /// Builds a playable video from a pasted [link]. Throws
  /// [ValidationException] unless it is an absolute http(s) URL.
  Video customVideo(String link) {
    final url = link.trim();
    final uri = Uri.tryParse(url);
    final valid =
        uri != null &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'http' || uri.scheme == 'https');
    if (!valid) {
      throw const ValidationException(
        fieldErrors: {
          'url': ['invalid'],
        },
      );
    }
    return Video(
      id: customVideoId,
      title: uri.host,
      description: url,
      url: url,
      durationSeconds: 0,
    );
  }

  Future<Set<String>> favoriteIds() async {
    final prefs = await _prefs;
    return prefs.getStringList(videoFavoritesKey).toSet();
  }

  /// Adds or removes [id] and returns the new favorites.
  Future<Set<String>> toggleFavorite(String id) async {
    final prefs = await _prefs;
    final ids = prefs.getStringList(videoFavoritesKey).toSet();
    if (!ids.remove(id)) ids.add(id);
    await prefs.setStringList(videoFavoritesKey, ids.toList());
    return ids;
  }

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on AppException {
      rethrow;
    } on DioException catch (error, stack) {
      // The Dio error-mapping interceptor already wrapped an AppException.
      final inner = error.error;
      throw inner is AppException ? inner : mapError(error, stack);
    } on Object catch (error, stack) {
      throw mapError(error, stack);
    }
  }
}

/// The source the repository reads from: mock or real, decided by
/// [videosUseMockSource] in this one place.
@Riverpod(keepAlive: true)
VideosRemoteSource videosSource(Ref ref) {
  if (videosUseMockSource) return VideosMockSource();
  return VideosRemoteSource(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
VideosRepository videosRepository(Ref ref) {
  return VideosRepository(
    ref.watch(videosSourceProvider),
    ref.watch(prefsStorageProvider.future),
  );
}

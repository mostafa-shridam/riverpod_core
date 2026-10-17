import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/storage/cache/cache_policy.dart';
import 'package:riverpod_core/core/storage/cache/cache_store.dart';
import 'package:riverpod_core/core/storage/cache/cached_repository_helper.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/features/videos/data/models/video.dart';
import 'package:riverpod_core/features/videos/data/models/video_feed.dart';
import 'package:riverpod_core/features/videos/data/sources/mock_scenario.dart';
import 'package:riverpod_core/features/videos/data/sources/sample_videos.dart';
import 'package:riverpod_core/features/videos/data/sources/videos_mock_source.dart';
import 'package:riverpod_core/features/videos/data/sources/videos_remote_source.dart';
import 'package:riverpod_core/features/videos/data/videos_repository.dart';

import '../../../helpers/helpers.dart';
import '../videos_test_support.dart';

const _videoJson = {
  'id': 'a',
  'title': 'A',
  'description': 'About A',
  'url': 'https://example.com/a.mp4',
  'durationSeconds': 12,
};

/// A cache helper over the same test storage as the prefs in one test.
Future<CachedRepositoryHelper> _cacheHelper() async =>
    CachedRepositoryHelper(await fakeCacheStore());

Future<VideosRepository> _mockRepository([
  MockScenario scenario = MockScenario.success,
]) async {
  final prefs = await fakePrefsStorage();
  return VideosRepository(
    fastSource(scenario),
    Future.value(prefs),
    await _cacheHelper(),
  );
}

/// Repository on the real remote source with a fake transport.
Future<({VideosRepository repository, FakeHttpAdapter adapter})> _remote({
  Map<String, Object> prefsValues = const {},
}) async {
  final adapter = FakeHttpAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
    ..httpClientAdapter = adapter;
  final prefs = await fakePrefsStorage(prefsValues);
  return (
    repository: VideosRepository(
      VideosRemoteSource(dio),
      Future.value(prefs),
      await _cacheHelper(),
    ),
    adapter: adapter,
  );
}

void main() {
  group('mock source', () {
    test('success returns every sample video', () async {
      final feed = await (await _mockRepository()).fetchFeed();
      expect(feed.videos, sampleVideos);
      expect(feed.hasPartialError, isFalse);
    });

    test('empty returns no videos', () async {
      final feed = await (await _mockRepository(
        MockScenario.empty,
      )).fetchFeed();
      expect(feed.videos, isEmpty);
    });

    test('partial returns some videos and flags the failure', () async {
      final feed = await (await _mockRepository(
        MockScenario.partial,
      )).fetchFeed();
      expect(feed.videos, hasLength(4));
      expect(feed.hasPartialError, isTrue);
    });

    test('slow still succeeds, after the slow delay', () async {
      final feed = await (await _mockRepository(MockScenario.slow)).fetchFeed();
      expect(feed.videos, sampleVideos);
    });

    test('error throws ServerException', () async {
      final repository = await _mockRepository(MockScenario.error);
      await expectLater(
        repository.fetchFeed(),
        throwsA(isA<ServerException>()),
      );
      await expectLater(
        repository.fetchVideo('bee'),
        throwsA(isA<ServerException>()),
      );
    });

    test('offline throws NetworkException', () async {
      final repository = await _mockRepository(MockScenario.offline);
      await expectLater(
        repository.fetchFeed(),
        throwsA(isA<NetworkException>()),
      );
      await expectLater(
        repository.fetchVideo('bee'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('an unknown id throws NotFoundException', () async {
      final repository = await _mockRepository();
      await expectLater(
        repository.fetchVideo('missing'),
        throwsA(isA<NotFoundException>()),
      );
      expect((await repository.fetchVideo('bee')).id, 'bee');
    });

    test('simulate switches the scenario of the mock only', () async {
      final repository = await _mockRepository();
      expect(repository.supportsSimulation, isTrue);
      repository.simulate(MockScenario.empty);
      expect(repository.scenario, MockScenario.empty);
      expect((await repository.fetchFeed()).videos, isEmpty);
    });

    test('latency is injectable', () async {
      final source = VideosMockSource(latency: const Duration(seconds: 30));
      // Never awaited: only checks that the answer is still pending.
      var done = false;
      source.fetchVideos().then((_) => done = true).ignore();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(done, isFalse);
    });
  });

  group('remote source and error mapping', () {
    test('maps the JSON list to models', () async {
      final r = await _remote();
      r.adapter.enqueueJson(200, {
        'items': [_videoJson],
        'partial': true,
      });

      final feed = await r.repository.fetchFeed();

      expect(feed.videos.single.title, 'A');
      expect(feed.videos.single.duration, const Duration(seconds: 12));
      expect(feed.hasPartialError, isTrue);
      expect(r.adapter.requests.single.uri.path, videosEndpoint);
    });

    test('partial defaults to false and one video maps by id', () async {
      final r = await _remote();
      r.adapter
        ..enqueueJson(200, {
          'items': [_videoJson],
        })
        ..enqueueJson(200, _videoJson);

      expect((await r.repository.fetchFeed()).hasPartialError, isFalse);
      final video = await r.repository.fetchVideo('a');
      expect(video, isA<Video>().having((v) => v.id, 'id', 'a'));
      expect(r.adapter.requests.last.uri.path, '$videosEndpoint/a');
    });

    DioException dioError(DioExceptionType type) =>
        DioException(requestOptions: RequestOptions(), type: type);

    final cases =
        <String, ({void Function(FakeHttpAdapter) queue, Matcher expected})>{
          '401': (
            queue: (a) => a.enqueueJson(401, {}),
            expected: isA<UnauthorizedException>(),
          ),
          '403': (
            queue: (a) => a.enqueueJson(403, {}),
            expected: isA<ForbiddenException>(),
          ),
          '404': (
            queue: (a) => a.enqueueJson(404, {}),
            expected: isA<NotFoundException>(),
          ),
          '500': (
            queue: (a) => a.enqueueJson(500, {}),
            expected: isA<ServerException>(),
          ),
          'connection error': (
            queue: (a) =>
                a.enqueueError(dioError(DioExceptionType.connectionError)),
            expected: isA<NetworkException>(),
          ),
          'timeout': (
            queue: (a) =>
                a.enqueueError(dioError(DioExceptionType.receiveTimeout)),
            expected: isA<RequestTimeoutException>(),
          ),
        };
    for (final entry in cases.entries) {
      test('${entry.key} becomes ${entry.value.expected}', () async {
        final r = await _remote();
        entry.value.queue(r.adapter);
        await expectLater(
          r.repository.fetchFeed(),
          throwsA(entry.value.expected),
        );
      });
    }

    test('an unexpected error becomes UnknownException', () async {
      final r = await _remote();
      r.adapter.enqueueError(StateError('boom'));
      await expectLater(
        r.repository.fetchFeed(),
        throwsA(isA<UnknownException>()),
      );
    });

    test('the real source does not support simulation', () async {
      final r = await _remote();
      expect(r.repository.supportsSimulation, isFalse);
      r.repository.simulate(MockScenario.error);
      expect(r.repository.scenario, MockScenario.success);
    });
  });

  group('related videos', () {
    test('excludes the current video and keeps four', () async {
      final repository = await _mockRepository();
      final related = await repository.fetchRelated('bee');
      expect(related, hasLength(4));
      expect(related.any((v) => v.id == 'bee'), isFalse);
    });

    test('a failing list throws', () async {
      final repository = await _mockRepository(MockScenario.error);
      await expectLater(
        repository.fetchRelated('bee'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('custom link', () {
    test('accepts http and https links', () async {
      final repository = await _mockRepository();
      final video = repository.customVideo(' https://example.com/x.m3u8 ');
      expect(video.id, customVideoId);
      expect(video.url, 'https://example.com/x.m3u8');
      expect(video.title, 'example.com');
      expect(repository.customVideo('http://a.test/v.mp4').url, isNotEmpty);
    });

    test('rejects anything else with ValidationException', () async {
      final repository = await _mockRepository();
      for (final bad in [
        '',
        'abc',
        'ftp://a.test/v.mp4',
        'https://',
        '/v.mp4',
      ]) {
        expect(
          () => repository.customVideo(bad),
          throwsA(isA<ValidationException>()),
          reason: bad,
        );
      }
    });
  });

  group('favorites', () {
    test('start empty', () async {
      expect(await (await _mockRepository()).favoriteIds(), isEmpty);
    });

    test('toggle adds, removes and persists in prefs', () async {
      final prefs = await fakePrefsStorage();
      final repository = VideosRepository(
        fastSource(),
        Future.value(prefs),
        await _cacheHelper(),
      );

      expect(await repository.toggleFavorite('bee'), {'bee'});
      expect(await repository.toggleFavorite('sintel'), {'bee', 'sintel'});
      expect(prefs.getStringList(videoFavoritesKey), ['bee', 'sintel']);

      expect(await repository.toggleFavorite('bee'), {'sintel'});
      expect(await repository.favoriteIds(), {'sintel'});
    });

    test('are read from existing prefs and cleared on logout', () async {
      final prefs = await fakePrefsStorage({
        videoFavoritesKey: ['bee'],
      });
      final repository = VideosRepository(
        fastSource(),
        Future.value(prefs),
        await _cacheHelper(),
      );
      expect(await repository.favoriteIds(), {'bee'});

      await prefs.clearUserScoped();
      expect(await repository.favoriteIds(), isEmpty);
    });

    test('the key is user scoped', () {
      expect(videoFavoritesKey, startsWith(PrefKeys.userPrefix));
    });
  });

  group('models', () {
    test('Video round trips through JSON', () {
      final video = Video.fromJson(_videoJson);
      expect(Video.fromJson(video.toJson()), video);
      expect(video.thumbnailUrl, isNull);
    });

    test('sample catalogue follows D-029', () {
      expect(sampleVideos, hasLength(7));
      expect(sampleVideos.map((v) => v.id).toSet(), hasLength(7));
      expect(sampleVideos.where((v) => v.url.contains('.m3u8')), hasLength(2));
      expect(
        sampleVideos.where((v) => v.url.contains('test-videos.co.uk')),
        hasLength(3),
      );
      expect(
        sampleVideos.where((v) => v.url.contains('flutter.github.io')),
        hasLength(2),
      );
    });
  });

  group('fetchFeed cache-first (D-038)', () {
    late CacheStore store;
    late DateTime now;
    late _FeedSource source;
    late VideosRepository repository;

    setUp(() async {
      final storage = await openTestStorage();
      store = CacheStore(storage.cache);
      now = DateTime.now();
      source = _FeedSource(_feedOf('a'));
      final prefs = await fakePrefsStorage();
      repository = VideosRepository(
        source,
        Future.value(prefs),
        CachedRepositoryHelper(store, clock: () => now),
      );
    });

    String payloadOf(String id) => jsonEncode(_feedOf(id).toJson());

    Future<void> seed(String id) => store.write(
      key: cacheKey(videosFeedKey),
      payload: payloadOf(id),
      savedAt: now,
    );

    /// Waits until the background revalidation has stored [id].
    Future<void> settle(String id) async {
      for (
        var i = 0;
        i < 500 &&
            store.read(cacheKey(videosFeedKey))!.payload != payloadOf(id);
        i++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
    }

    test(
      'a cached feed comes back at once, the network answer after it',
      () async {
        await seed('a');
        final gate = Completer<void>();
        source
          ..feed = _feedOf('b')
          ..gate = gate;

        final first = await repository.fetchFeed();
        expect(
          first.videos.single.id,
          'a',
          reason: 'no waiting for the network',
        );

        gate.complete();
        await settle('b');
        expect((await repository.fetchFeed()).videos.single.id, 'b');
      },
    );

    test('an unchanged answer leaves the cached copy as it is', () async {
      await seed('a');
      final before = store.read(cacheKey(videosFeedKey))!.payload;

      expect((await repository.fetchFeed()).videos.single.id, 'a');
      for (var i = 0; i < 500 && source.calls == 0; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }

      expect(source.calls, 1, reason: 'revalidated in the background');
      expect(store.read(cacheKey(videosFeedKey))!.payload, before);
    });

    test(
      'fresh waits for the network, returns that answer and stores it',
      () async {
        await seed('a');
        final gate = Completer<void>();
        source
          ..feed = _feedOf('b')
          ..gate = gate;

        final pending = repository.fetchFeed(fresh: true);
        gate.complete();

        expect((await pending).videos.single.id, 'b');
        expect(store.read(cacheKey(videosFeedKey))!.payload, payloadOf('b'));
      },
    );

    test('fresh raises the error even when a cached feed exists', () async {
      await seed('a');
      source.error = const NetworkException();

      await expectLater(
        repository.fetchFeed(fresh: true),
        throwsA(isA<NetworkException>()),
      );
      expect(store.read(cacheKey(videosFeedKey))!.payload, payloadOf('a'));
    });
  });
}

/// Mock source whose feed and failure a test sets; its answer waits on [gate].
class _FeedSource extends VideosMockSource {
  _FeedSource(this.feed) : super(latency: Duration.zero);

  VideoFeed feed;
  Completer<void>? gate;
  Object? error;
  int calls = 0;

  @override
  Future<VideoFeed> fetchVideos() async {
    calls++;
    await gate?.future;
    final failure = error;
    if (failure != null) throw failure;
    return feed;
  }
}

VideoFeed _feedOf(String id) => VideoFeed(
  videos: [
    Video.fromJson({..._videoJson, 'id': id, 'title': id}),
  ],
);

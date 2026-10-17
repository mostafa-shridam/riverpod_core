import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/config/log_level.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/storage/cache/cache_store.dart';
import 'package:riverpod_core/core/storage/cache/cached_repository_helper.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/features/videos/data/models/video.dart';
import 'package:riverpod_core/features/videos/data/models/video_feed.dart';
import 'package:riverpod_core/features/videos/data/sources/mock_scenario.dart';
import 'package:riverpod_core/features/videos/data/sources/videos_mock_source.dart';
import 'package:riverpod_core/features/videos/data/videos_repository.dart';

import '../../helpers/fake_connectivity.dart';
import '../../helpers/fake_prefs_storage.dart';

/// A valid config for [flavor]; the feature only reads the flavor.
AppConfig testConfig([Flavor flavor = Flavor.dev]) => AppConfig(
  flavor: flavor,
  appName: 'Test',
  apiBaseUrl: 'https://api.example.test',
  connectTimeout: const Duration(seconds: 15),
  receiveTimeout: const Duration(seconds: 30),
  logLevel: LogLevel.error,
  enableCrashReporting: false,
  enableAnalytics: false,
);

/// Mock source with no latency (`slow` answers after a few ms).
VideosMockSource fastSource([MockScenario scenario = MockScenario.success]) =>
    VideosMockSource(
      scenario: scenario,
      latency: Duration.zero,
      slowLatency: const Duration(milliseconds: 50),
    );

/// Mock source whose answers wait for [gate], so a test can look at the
/// loading and refreshing states before releasing it.
class GatedSource extends VideosMockSource {
  GatedSource({super.scenario}) : super(latency: Duration.zero);

  Completer<void>? gate;

  @override
  Future<VideoFeed> fetchVideos() async {
    final pending = gate;
    if (pending != null) await pending.future;
    return super.fetchVideos();
  }

  @override
  Future<Video> fetchVideo(String id) async {
    final pending = gate;
    if (pending != null) await pending.future;
    return super.fetchVideo(id);
  }
}

/// Mock source whose list fails while a single video still loads, to show
/// the partial state of the detail page.
class ListFailsSource extends VideosMockSource {
  ListFailsSource() : super(latency: Duration.zero);

  bool failList = true;

  @override
  Future<VideoFeed> fetchVideos() {
    if (failList) return Future.error(const NetworkException());
    return super.fetchVideos();
  }
}

/// Provider overrides every videos test needs. The cache shares the test
/// storage the prefs are on, so one test sees one store.
Future<List<Override>> videosOverrides({
  required VideosMockSource source,
  required PrefsStorage prefs,
  FakeConnectivity? connectivity,
  Flavor flavor = Flavor.dev,
}) async {
  final storage = await openTestStorage();
  return [
    appConfigProvider.overrideWithValue(testConfig(flavor)),
    videosSourceProvider.overrideWithValue(source),
    prefsStorageProvider.overrideWith((ref) => Future.value(prefs)),
    cachedRepositoryHelperProvider.overrideWithValue(
      CachedRepositoryHelper(CacheStore(storage.cache)),
    ),
    (connectivity ?? FakeConnectivity()).providerOverride,
  ];
}

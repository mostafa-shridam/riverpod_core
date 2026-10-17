import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/features/videos/data/sources/mock_scenario.dart';
import 'package:riverpod_core/features/videos/data/sources/sample_videos.dart';
import 'package:riverpod_core/features/videos/providers/favorite_videos_controller.dart';
import 'package:riverpod_core/features/videos/providers/mock_scenario_controller.dart';
import 'package:riverpod_core/features/videos/providers/video_detail_providers.dart';
import 'package:riverpod_core/features/videos/providers/videos_controller.dart';
import 'package:riverpod_core/features/videos/providers/videos_state.dart';

import '../../../helpers/helpers.dart';
import '../videos_test_support.dart';

Future<ProviderContainer> _container(
  GatedSource source, {
  Flavor flavor = Flavor.dev,
  Map<String, Object> prefsValues = const {},
}) async {
  final prefs = await fakePrefsStorage(prefsValues);
  final container = ProviderContainer(
    // D-032: no silent retries, so failures settle at once.
    retry: (_, _) => null,
    overrides: await videosOverrides(
      source: source,
      prefs: prefs,
      flavor: flavor,
    ),
  );
  addTearDown(container.dispose);
  // Keeps the auto-dispose controller alive between reads.
  container.listen(videosControllerProvider, (_, _) {});
  return container;
}

void main() {
  group('VideosController', () {
    test('starts loading, then holds the videos', () async {
      final container = await _container(GatedSource());
      expect(container.read(videosControllerProvider).isLoading, isTrue);

      final state = await container.read(videosControllerProvider.future);

      expect(state.videos, sampleVideos);
      expect(state.visible, sampleVideos);
      expect(state.hasPartialError, isFalse);
      expect(state.query, isEmpty);
    });

    test('an empty answer is data with no videos', () async {
      final container = await _container(
        GatedSource(scenario: MockScenario.empty),
      );
      final state = await container.read(videosControllerProvider.future);
      expect(state.videos, isEmpty);
    });

    test('failures end in AsyncError holding an AppException', () async {
      final container = await _container(
        GatedSource(scenario: MockScenario.error),
      );
      await expectLater(
        container.read(videosControllerProvider.future),
        throwsA(isA<ServerException>()),
      );
      expect(
        container.read(videosControllerProvider).error,
        isA<ServerException>(),
      );

      final offline = await _container(
        GatedSource(scenario: MockScenario.offline),
      );
      await expectLater(
        offline.read(videosControllerProvider.future),
        throwsA(isA<NetworkException>()),
      );
    });

    test('a partial answer sets the partial flag', () async {
      final container = await _container(
        GatedSource(scenario: MockScenario.partial),
      );
      final state = await container.read(videosControllerProvider.future);
      expect(state.hasPartialError, isTrue);
      expect(state.videos, isNotEmpty);
    });

    test('search filters title and description, ignoring case', () async {
      final container = await _container(GatedSource());
      await container.read(videosControllerProvider.future);
      final controller = container.read(videosControllerProvider.notifier);

      controller.search('  BEE ');
      final byTitle = container.read(videosControllerProvider).requireValue;
      expect(byTitle.visible.map((v) => v.id), contains('bee'));
      expect(byTitle.visible.length, lessThan(sampleVideos.length));
      expect(byTitle.videos, sampleVideos, reason: 'the list is kept');

      controller.search('pollen');
      expect(
        container
            .read(videosControllerProvider)
            .requireValue
            .visible
            .map((v) => v.id),
        ['bee'],
      );

      controller.search('zzz-no-match');
      expect(
        container.read(videosControllerProvider).requireValue.visible,
        isEmpty,
      );

      controller.search('');
      expect(
        container.read(videosControllerProvider).requireValue.visible,
        sampleVideos,
      );
    });

    test('search before the first load is applied to it', () async {
      final container = await _container(GatedSource());
      container.read(videosControllerProvider.notifier).search('bee');
      final state = await container.read(videosControllerProvider.future);
      expect(state.query, 'bee');
    });

    test('refresh keeps the previous data while loading', () async {
      final source = GatedSource();
      final container = await _container(source);
      await container.read(videosControllerProvider.future);

      source.gate = Completer<void>();
      final seen = <AsyncValue<VideosState>>[];
      container.listen(videosControllerProvider, (_, next) => seen.add(next));
      final done = container.read(videosControllerProvider.notifier).refresh();
      await Future<void>.delayed(Duration.zero);

      final during = container.read(videosControllerProvider);
      expect(during.isLoading, isTrue);
      expect(during.hasValue, isTrue, reason: 'previous data stays');

      source.gate!.complete();
      await done;
      final after = container.read(videosControllerProvider);
      expect(after.isLoading, isFalse);
      expect(after.requireValue.videos, sampleVideos);
    });

    test('a failed refresh keeps the old data next to the error', () async {
      final source = GatedSource();
      final container = await _container(source);
      await container.read(videosControllerProvider.future);

      source.scenario = MockScenario.error;
      await container.read(videosControllerProvider.notifier).refresh();

      final state = container.read(videosControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<ServerException>());
      expect(state.hasValue, isTrue);
      expect(state.requireValue.videos, sampleVideos);
    });

    test('refresh recovers after an error', () async {
      final source = GatedSource(scenario: MockScenario.error);
      final container = await _container(source);
      await container
          .read(videosControllerProvider.future)
          .then<void>((_) {}, onError: (Object _) {});

      source.scenario = MockScenario.success;
      await container.read(videosControllerProvider.notifier).refresh();

      expect(
        container.read(videosControllerProvider).requireValue.videos,
        sampleVideos,
      );
    });

    test('reload drops the data first, and keeps the search text', () async {
      final source = GatedSource();
      final container = await _container(source);
      await container.read(videosControllerProvider.future);
      final controller = container.read(videosControllerProvider.notifier)
        ..search('bee');

      source.gate = Completer<void>();
      final done = controller.reload();
      await Future<void>.delayed(Duration.zero);
      final during = container.read(videosControllerProvider);
      expect(during.isLoading, isTrue);
      expect(controller.dropsPreviousData, isTrue);

      source.gate!.complete();
      await done;
      expect(controller.dropsPreviousData, isFalse);
      expect(
        container.read(videosControllerProvider).requireValue.query,
        'bee',
      );
    });
  });

  group('simulation', () {
    test('is enabled in dev and staging with the mock source', () async {
      for (final flavor in [Flavor.dev, Flavor.staging]) {
        final container = await _container(GatedSource(), flavor: flavor);
        expect(container.read(videosSimulationEnabledProvider), isTrue);
      }
    });

    test('is never enabled in prod', () async {
      final container = await _container(GatedSource(), flavor: Flavor.prod);
      expect(container.read(videosSimulationEnabledProvider), isFalse);
    });

    test('select switches the scenario the list answers with', () async {
      final container = await _container(GatedSource());
      expect(
        container.read(mockScenarioControllerProvider),
        MockScenario.success,
      );
      container.listen(mockScenarioControllerProvider, (_, _) {});

      container
          .read(mockScenarioControllerProvider.notifier)
          .select(MockScenario.empty);
      await container.read(videosControllerProvider.notifier).reload();

      expect(
        container.read(mockScenarioControllerProvider),
        MockScenario.empty,
      );
      expect(
        container.read(videosControllerProvider).requireValue.videos,
        isEmpty,
      );
    });
  });

  group('FavoriteVideosController', () {
    test('loads saved favorites and toggles them', () async {
      final container = await _container(
        GatedSource(),
        prefsValues: {
          'user.videos.favorites': ['bee'],
        },
      );
      container.listen(favoriteVideosControllerProvider, (_, _) {});
      expect(await container.read(favoriteVideosControllerProvider.future), {
        'bee',
      });

      final controller = container.read(
        favoriteVideosControllerProvider.notifier,
      );
      await controller.toggle('sintel');
      expect(container.read(favoriteVideosControllerProvider).value, {
        'bee',
        'sintel',
      });

      await controller.toggle('bee');
      expect(container.read(favoriteVideosControllerProvider).value, {
        'sintel',
      });
    });
  });

  group('detail providers', () {
    test('videoDetail loads by id, or builds a custom video', () async {
      final container = await _container(GatedSource());
      expect(
        (await container.read(videoDetailProvider('sintel').future)).id,
        'sintel',
      );
      final custom = await container.read(
        videoDetailProvider('custom', customUrl: 'https://a.test/v.mp4').future,
      );
      expect(custom.url, 'https://a.test/v.mp4');
    });

    test('videoDetail fails with NotFound and Validation', () async {
      final container = await _container(GatedSource());
      await expectLater(
        container.read(videoDetailProvider('nope').future),
        throwsA(isA<NotFoundException>()),
      );
      await expectLater(
        container.read(
          videoDetailProvider('custom', customUrl: 'not a link').future,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('relatedVideos excludes the video itself', () async {
      final container = await _container(GatedSource());
      final related = await container.read(relatedVideosProvider('bee').future);
      expect(related, hasLength(4));
      expect(related.any((v) => v.id == 'bee'), isFalse);
    });
  });
}

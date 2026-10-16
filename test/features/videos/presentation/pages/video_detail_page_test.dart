import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/async/error_state.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/banner/app_banner.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_player.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_source.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/features/videos/data/sources/mock_scenario.dart';
import 'package:riverpod_core/features/videos/presentation/pages/video_detail_page.dart';
import 'package:riverpod_core/features/videos/presentation/widgets/video_detail_skeleton.dart';

import '../../../../core/design_system/widgets/display/ds_test_harness.dart';
import '../../../../core/design_system/widgets/media/fake_video_backend.dart';
import '../../../../helpers/fake_connectivity.dart';
import '../../../../helpers/fake_prefs_storage.dart';
import '../../videos_test_support.dart';

class _Detail {
  _Detail(this.factory, this.prefs, this.source);

  final FakeVideoFactory factory;
  final PrefsStorage prefs;
  final ListFailsSource source;
}

Future<_Detail> _pump(
  WidgetTester tester, {
  String id = 'sintel',
  String? customUrl,
  MockScenario scenario = MockScenario.success,
  bool failRelated = false,
  Map<String, Object> savedPrefs = const {},
  String locale = 'en',
  bool dark = false,
  double textScale = 1,
  Size size = phoneSize,
}) async {
  final factory = FakeVideoFactory();
  final prefs = (await tester.runAsync(() => fakePrefsStorage(savedPrefs)))!;
  final source = ListFailsSource()
    ..failList = failRelated
    ..scenario = scenario;
  await pumpDs(
    tester,
    ProviderScope(
      retry: (_, _) => null, // D-032
      overrides: videosOverrides(
        source: source,
        prefs: prefs,
        connectivity: FakeConnectivity(),
      ),
      child: VideoDetailPage(
        id: id,
        customUrl: customUrl,
        backendFactory: factory.call,
      ),
    ),
    locale: locale,
    dark: dark,
    textScale: textScale,
    size: size,
    scaffold: false,
  );
  return _Detail(factory, prefs, source);
}

void main() {
  group('detail page', () {
    testWidgets('shows the player, title and description', (tester) async {
      final d = await _pump(tester);

      expect(find.byType(AppVideoPlayer), findsOneWidget);
      expect(find.text('The dragon quest'), findsOneWidget);
      expect(find.textContaining('animated fantasy trailer'), findsOneWidget);
      expect(d.factory.created, hasLength(1));
      expect(
        d.factory.last.source,
        const AppVideoSource.network(
          'https://test-videos.co.uk/vids/sintel/mp4/h264/720/Sintel_720_10s_5MB.mp4',
        ),
      );
    });

    testWidgets('starts playing automatically', (tester) async {
      final d = await _pump(tester);
      await tester.pump();
      expect(d.factory.last.calls, containsAllInOrder(['initialize', 'play']));
    });

    testWidgets('lists related videos without the current one', (tester) async {
      await _pump(tester, id: 'bee');
      expect(find.text('Related videos'), findsOneWidget);
      expect(find.text('Bee at work'), findsOneWidget, reason: 'the title');
      // Four related tiles, none of them the current video.
      expect(find.text('Butterfly in the garden'), findsOneWidget);
    });

    testWidgets('favorite toggle persists and flips the label', (tester) async {
      final d = await _pump(tester);
      expect(find.text('Add to favorites'), findsOneWidget);

      await tester.ensureVisible(find.text('Add to favorites'));
      await tester.tap(find.text('Add to favorites'));
      await tester.pumpAndSettle();

      expect(find.text('Remove from favorites'), findsOneWidget);
      expect(d.prefs.getStringList('user.videos.favorites'), ['sintel']);

      await tester.tap(find.text('Remove from favorites'));
      await tester.pumpAndSettle();
      expect(find.text('Add to favorites'), findsOneWidget);
      expect(d.prefs.getStringList('user.videos.favorites'), isEmpty);
    });

    testWidgets('a saved favorite shows as favorite', (tester) async {
      await _pump(
        tester,
        savedPrefs: {
          'user.videos.favorites': ['sintel'],
        },
      );
      expect(find.text('Remove from favorites'), findsOneWidget);
    });

    testWidgets('related failure is a partial state with retry', (
      tester,
    ) async {
      final d = await _pump(tester, failRelated: true);

      expect(find.text('The dragon quest'), findsOneWidget);
      expect(find.byType(AppBanner), findsOneWidget);
      expect(find.text('Related videos could not be loaded.'), findsOneWidget);

      d.source.failList = false;
      await tester.ensureVisible(find.byType(AppBanner));
      await tester.tap(
        find.descendant(
          of: find.byType(AppBanner),
          matching: find.byType(TextButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppBanner), findsNothing);
      expect(find.text('Related videos'), findsOneWidget);
    });

    testWidgets('a custom link plays that URL and has no favorite', (
      tester,
    ) async {
      final d = await _pump(
        tester,
        id: 'custom',
        customUrl: 'https://media.example.com/clip.m3u8',
      );
      expect(
        d.factory.last.source,
        const AppVideoSource.network('https://media.example.com/clip.m3u8'),
      );
      expect(find.text('Custom link'), findsOneWidget);
      expect(find.text('https://media.example.com/clip.m3u8'), findsOneWidget);
      expect(find.text('Add to favorites'), findsNothing);
    });

    testWidgets('an invalid custom link shows the error state', (tester) async {
      await _pump(tester, id: 'custom', customUrl: 'nope');
      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.byType(AppVideoPlayer), findsNothing);
    });

    testWidgets('unknown id and server error show ErrorState with retry', (
      tester,
    ) async {
      await _pump(tester, id: 'missing');
      expect(find.byType(ErrorState), findsOneWidget);

      final d = await _pump(tester, scenario: MockScenario.error);
      expect(find.byType(ErrorState), findsOneWidget);
      d.source.scenario = MockScenario.success;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.byType(AppVideoPlayer), findsOneWidget);
    });

    testWidgets('loading shows the skeleton', (tester) async {
      final prefs = (await tester.runAsync(fakePrefsStorage))!;
      final source = GatedSource()..gate = Completer<void>();
      await pumpDs(
        tester,
        ProviderScope(
          retry: (_, _) => null,
          overrides: videosOverrides(source: source, prefs: prefs),
          child: VideoDetailPage(
            id: 'bee',
            backendFactory: FakeVideoFactory().call,
          ),
        ),
        scaffold: false,
      );
      expect(find.byType(VideoDetailSkeleton), findsOneWidget);
      expect(find.byType(AppVideoPlayer), findsNothing);

      source.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(VideoDetailSkeleton), findsNothing);
      expect(find.byType(AppVideoPlayer), findsOneWidget);
    });

    testWidgets('tablet and text scale 2.0 render without overflow', (
      tester,
    ) async {
      await _pump(tester, size: tabletSize);
      expect(tester.takeException(), isNull);
      await _pump(tester, textScale: 2, locale: 'ar');
      expect(tester.takeException(), isNull);
    });
  });

  group('goldens', () {
    for (final mode in goldenModes) {
      testWidgets('detail ${mode.name}', (tester) async {
        await _pump(tester, locale: mode.locale, dark: mode.dark);
        await expectLater(
          find.byType(Scaffold).first,
          matchesGoldenFile(
            '../../../../goldens/videos/detail_${mode.name}.png',
          ),
        );
      });
    }
  });
}

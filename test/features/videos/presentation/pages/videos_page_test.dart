import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/design_system/widgets/async/empty_state.dart';
import 'package:riverpod_core/core/design_system/widgets/async/error_state.dart';
import 'package:riverpod_core/core/design_system/widgets/async/offline_banner.dart';
import 'package:riverpod_core/core/design_system/widgets/bottom_sheets/app_selection_sheet.dart';
import 'package:riverpod_core/core/design_system/widgets/dialogs/app_input_dialog.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/banner/app_banner.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/features/videos/data/sources/mock_scenario.dart';
import 'package:riverpod_core/features/videos/presentation/pages/videos_page.dart';
import 'package:riverpod_core/features/videos/presentation/widgets/custom_url_button.dart';
import 'package:riverpod_core/features/videos/presentation/widgets/simulate_menu_button.dart';
import 'package:riverpod_core/features/videos/presentation/widgets/video_card.dart';
import 'package:riverpod_core/features/videos/presentation/widgets/video_list_skeleton.dart';
import 'package:riverpod_core/features/videos/providers/videos_controller.dart';

import '../../../../core/design_system/widgets/display/ds_test_harness.dart';
import '../../../../helpers/fake_connectivity.dart';
import '../../../../helpers/fake_prefs_storage.dart';
import '../../videos_test_support.dart';

class _Harness {
  _Harness(this.container, this.source, this.prefs, this.connectivity);

  final ProviderContainer container;
  final GatedSource source;
  final PrefsStorage prefs;
  final FakeConnectivity connectivity;
}

/// Pumps the list page on a [GatedSource]. Set `source.gate` in [prepare] to
/// hold the first answer.
Future<_Harness> _pump(
  WidgetTester tester, {
  MockScenario scenario = MockScenario.success,
  Flavor flavor = Flavor.dev,
  bool online = true,
  String locale = 'en',
  bool dark = false,
  double textScale = 1,
  Size size = phoneSize,
  void Function(GatedSource source)? prepare,
}) async {
  final source = GatedSource(scenario: scenario);
  prepare?.call(source);
  final prefs = (await tester.runAsync(fakePrefsStorage))!;
  final connectivity = FakeConnectivity(online: online);
  final container = ProviderContainer(
    retry: (_, _) => null, // D-032
    overrides: videosOverrides(
      source: source,
      prefs: prefs,
      connectivity: connectivity,
      flavor: flavor,
    ),
  );
  addTearDown(container.dispose);
  await pumpDs(
    tester,
    UncontrolledProviderScope(container: container, child: const VideosPage()),
    locale: locale,
    dark: dark,
    textScale: textScale,
    size: size,
    scaffold: false,
  );
  return _Harness(container, source, prefs, connectivity);
}

Finder get _cards => find.byType(VideoCard);

void main() {
  group('the 8 data states', () {
    testWidgets('loading: skeleton of the card layout', (tester) async {
      final h = await _pump(tester, prepare: (s) => s.gate = Completer());
      expect(find.byType(VideoListSkeleton), findsOneWidget);
      expect(_cards, findsWidgets, reason: 'the skeleton reuses VideoCard');
      expect(find.byType(EmptyState), findsNothing);
      h.source.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(VideoListSkeleton), findsNothing);
    });

    testWidgets('success: cards with title and duration badge', (tester) async {
      await _pump(tester);
      expect(find.text('Butterfly in the garden'), findsOneWidget);
      expect(find.text('0:07'), findsOneWidget);
      expect(find.byType(ErrorState), findsNothing);
      expect(find.byType(EmptyState), findsNothing);
    });

    testWidgets('empty: EmptyState', (tester) async {
      await _pump(tester, scenario: MockScenario.empty);
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No videos yet'), findsOneWidget);
      expect(_cards, findsNothing);
    });

    testWidgets('error: ErrorState with retry that recovers', (tester) async {
      final h = await _pump(tester, scenario: MockScenario.error);
      final error = tester.widget<ErrorState>(find.byType(ErrorState));
      expect(error.isOffline, isFalse);
      expect(error.onRetry, isNotNull);

      h.source.scenario = MockScenario.success;
      error.onRetry!();
      await tester.pumpAndSettle();
      expect(find.byType(ErrorState), findsNothing);
      expect(find.text('Butterfly in the garden'), findsOneWidget);
    });

    testWidgets('offline: ErrorState offline variant', (tester) async {
      await _pump(tester, scenario: MockScenario.offline, online: false);
      expect(
        tester.widget<ErrorState>(find.byType(ErrorState)).isOffline,
        isTrue,
      );
    });

    testWidgets('stale: failed reload keeps data with a banner', (
      tester,
    ) async {
      final h = await _pump(tester);
      h.source.scenario = MockScenario.error;
      unawaited(h.container.read(videosControllerProvider.notifier).refresh());
      await tester.pumpAndSettle();

      expect(find.text('Butterfly in the garden'), findsOneWidget);
      expect(find.byType(ErrorState), findsNothing);
      expect(
        tester.widget<OfflineBanner>(find.byType(OfflineBanner)).isStale,
        isTrue,
      );
    });

    testWidgets('partial: data plus inline error row with retry', (
      tester,
    ) async {
      final h = await _pump(tester, scenario: MockScenario.partial);
      expect(find.text('Some videos could not be loaded.'), findsOneWidget);
      expect(find.byType(AppBanner), findsOneWidget);
      expect(find.text('Butterfly in the garden'), findsOneWidget);
      expect(
        h.container.read(videosControllerProvider).requireValue.videos,
        hasLength(4),
      );

      h.source.scenario = MockScenario.success;
      await tester.tap(
        find.descendant(
          of: find.byType(AppBanner),
          matching: find.byType(TextButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppBanner), findsNothing);
    });

    testWidgets('refreshing: data stays with a thin progress line', (
      tester,
    ) async {
      final h = await _pump(tester);
      h.source.gate = Completer();
      unawaited(h.container.read(videosControllerProvider.notifier).refresh());
      await tester.pump();
      await tester.pump();

      expect(find.text('Butterfly in the garden'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(VideoListSkeleton), findsNothing);

      h.source.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });

  group('interaction', () {
    testWidgets('pull to refresh reloads', (tester) async {
      final h = await _pump(tester, scenario: MockScenario.empty);
      h.source.scenario = MockScenario.success;
      await tester.fling(find.byType(EmptyState), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Butterfly in the garden'), findsOneWidget);
    });

    testWidgets('search filters the list and shows a no-results state', (
      tester,
    ) async {
      await _pump(tester);
      await tester.enterText(find.byType(TextField), 'jellyfish');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('Jellyfish drifting'), findsOneWidget);
      expect(find.text('Butterfly in the garden'), findsNothing);

      await tester.enterText(find.byType(TextField), 'zzz-none');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('No matching videos'), findsOneWidget);
      expect(_cards, findsNothing);
    });

    testWidgets('favorite toggle updates the icon and persists', (
      tester,
    ) async {
      final h = await _pump(tester);
      expect(find.byIcon(Icons.favorite_border_rounded), findsWidgets);

      await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(h.prefs.getStringList('user.videos.favorites'), ['butterfly']);
      expect(find.text('Added to favorites'), findsOneWidget);
    });

    testWidgets('the simulate menu shows every scenario in dev', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.byType(SimulateMenuButton), findsOneWidget);
      await tester.tap(find.byType(SimulateMenuButton));
      await tester.pumpAndSettle();
      expect(find.byType(AppSelectionSheet<MockScenario>), findsOneWidget);
      for (final label in [
        'Success',
        'Empty',
        'Server error',
        'Offline',
        'Slow network',
        'Partial failure',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('picking Empty reloads the list as empty', (tester) async {
      await _pump(tester);
      await tester.tap(find.byType(SimulateMenuButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Empty'));
      await tester.pumpAndSettle();
      expect(find.byType(EmptyState), findsOneWidget);
    });

    testWidgets('picking Offline shows the offline error state', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(find.byType(SimulateMenuButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Offline'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<ErrorState>(find.byType(ErrorState)).isOffline,
        isTrue,
      );
    });

    testWidgets('the simulate menu is hidden in prod', (tester) async {
      await _pump(tester, flavor: Flavor.prod);
      expect(find.byType(SimulateMenuButton), findsNothing);
      expect(find.byType(CustomUrlButton), findsOneWidget);
    });

    testWidgets('the custom link dialog rejects an invalid link', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(find.byType(CustomUrlButton));
      await tester.pumpAndSettle();
      expect(find.byType(AppInputDialog), findsOneWidget);

      await tester.enterText(
        find.descendant(
          of: find.byType(AppInputDialog),
          matching: find.byType(TextFormField),
        ),
        'not a link',
      );
      await tester.tap(find.text('Play'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid http or https link.'), findsOneWidget);
      expect(find.byType(AppInputDialog), findsOneWidget);
    });
  });

  group('layouts', () {
    testWidgets('tablet, text scale 2.0 and Arabic render without overflow', (
      tester,
    ) async {
      await _pump(tester, size: tabletSize, textScale: 2);
      expect(tester.takeException(), isNull);
      await _pump(tester, locale: 'ar', textScale: 2);
      expect(tester.takeException(), isNull);
      expect(find.text('الفيديوهات'), findsOneWidget);
    });
  });

  group('goldens', () {
    final scenarios = {
      'success': MockScenario.success,
      'empty': MockScenario.empty,
      'error': MockScenario.error,
    };
    for (final scene in scenarios.entries) {
      for (final mode in goldenModes) {
        testWidgets('${scene.key} ${mode.name}', (tester) async {
          await _pump(
            tester,
            scenario: scene.value,
            locale: mode.locale,
            dark: mode.dark,
          );
          await expectLater(
            find.byType(Scaffold).first,
            matchesGoldenFile(
              '../../../../goldens/videos/list_${scene.key}_${mode.name}.png',
            ),
          );
        });
      }
    }
  });
}

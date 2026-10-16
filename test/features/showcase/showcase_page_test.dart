import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/async/async_value_view.dart';
import 'package:riverpod_core/core/design_system/widgets/async/empty_state.dart';
import 'package:riverpod_core/core/design_system/widgets/async/error_state.dart';
import 'package:riverpod_core/core/design_system/widgets/async/skeleton_list.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_image.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_scaffold.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_player.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_chip_group.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/showcase_samples.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/states_section.dart';

import '../../core/design_system/widgets/display/ds_test_harness.dart';
import 'showcase_test_support.dart';

const _labels = {
  ShowcaseDataState.loading: 'Loading',
  ShowcaseDataState.empty: 'Empty',
  ShowcaseDataState.error: 'Error',
  ShowcaseDataState.offline: 'Offline',
  ShowcaseDataState.success: 'Success',
};

Finder _inDemo(Finder matching) => find.descendant(
  of: find.byType(AsyncValueView<List<String>>),
  matching: matching,
);

void main() {
  group('builds without overflow', () {
    for (final mode in goldenModes) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('${mode.name} at $scale x, phone', (tester) async {
          await pumpShowcase(
            tester,
            locale: mode.locale,
            dark: mode.dark,
            textScale: scale,
          );
          for (final key in showcaseSectionKeys) {
            await scrollTo(tester, find.byKey(ValueKey(key)));
            expect(tester.takeException(), isNull, reason: key);
          }
        });
      }
    }

    testWidgets('tablet, ar, scale 2.0', (tester) async {
      await pumpShowcase(tester, locale: 'ar', textScale: 2, size: tabletSize);
      for (final key in showcaseSectionKeys) {
        await scrollTo(tester, find.byKey(ValueKey(key)));
        expect(tester.takeException(), isNull, reason: key);
      }
    });
  });

  group('toggles', () {
    testWidgets('theme button switches light and dark', (tester) async {
      await pumpShowcase(tester);
      Brightness brightness() =>
          Theme.of(tester.element(find.byType(AppScaffold))).brightness;
      expect(brightness(), Brightness.light);
      await tester.tap(find.byKey(const ValueKey('toggle-theme')));
      await settle(tester);
      expect(brightness(), Brightness.dark);
      await tester.tap(find.byKey(const ValueKey('toggle-theme')));
      await settle(tester);
      expect(brightness(), Brightness.light);
    });

    testWidgets('locale button switches en to ar and back', (tester) async {
      await pumpShowcase(tester);
      TextDirection direction() =>
          Directionality.of(tester.element(find.byType(AppScaffold)));
      expect(direction(), TextDirection.ltr);
      await tester.tap(find.byKey(const ValueKey('toggle-locale')));
      await settle(tester);
      expect(direction(), TextDirection.rtl);
      await tester.tap(find.byKey(const ValueKey('toggle-locale')));
      await settle(tester);
      expect(direction(), TextDirection.ltr);
    });

    testWidgets('text scale slider scales the body only', (tester) async {
      await pumpShowcase(tester);
      double bodyScale() => MediaQuery.textScalerOf(
        tester.element(find.byKey(const ValueKey('showcase-list'))),
      ).scale(1);
      expect(bodyScale(), 1);
      await tester.drag(find.byType(Slider), const Offset(400, 0));
      await settle(tester);
      expect(bodyScale(), closeTo(2.0, 0.01));
      expect(tester.takeException(), isNull);
    });
  });

  group('media', () {
    testWidgets('plays the sample video and loads HLS on demand', (
      tester,
    ) async {
      await pumpShowcase(tester);
      await scrollTo(tester, find.byKey(const ValueKey('showcase-media')));
      expect(find.byType(AppVideoPlayer), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('load-hls')));
      await settle(tester);
      expect(find.byType(AppVideoPlayer), findsNWidgets(2));
    });
  });

  group('data states demo', () {
    testWidgets('each chip renders its state', (tester) async {
      await pumpShowcase(tester);
      await scrollTo(tester, find.byKey(const ValueKey('showcase-states')));

      Future<void> pick(ShowcaseDataState state) async {
        await tester.tap(
          find.descendant(
            of: find.byType(AppChipGroup<ShowcaseDataState>),
            matching: find.text(_labels[state]!),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
      }

      await pick(ShowcaseDataState.loading);
      expect(_inDemo(find.byType(SkeletonList)), findsOneWidget);
      await pick(ShowcaseDataState.empty);
      expect(_inDemo(find.byType(EmptyState)), findsOneWidget);
      await pick(ShowcaseDataState.error);
      expect(_inDemo(find.byType(ErrorState)), findsOneWidget);
      await pick(ShowcaseDataState.offline);
      expect(_inDemo(find.byType(ErrorState)), findsOneWidget);
      await pick(ShowcaseDataState.success);
      expect(_inDemo(find.byType(ListView)), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('images', () {
    // The error rendering itself is covered by app_image_test; the cache
    // manager needs platform channels, so here only the demo wiring is checked.
    testWidgets('shows one working and one broken URL', (tester) async {
      await pumpShowcase(tester);
      await scrollTo(
        tester,
        find.byKey(const ValueKey('showcase-broken-image')),
      );
      final broken = tester.widget<AppImage>(
        find.byKey(const ValueKey('showcase-broken-image')),
      );
      expect(broken.url, showcaseBrokenImageUrl);
      expect(
        find.byWidgetPredicate(
          (w) => w is AppImage && w.url == showcaseImageUrl,
        ),
        findsOneWidget,
      );
    });
  });
}

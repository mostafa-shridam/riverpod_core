import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/design_system/widgets/buttons/app_fab.dart';
import 'package:riverpod_core/design_system/widgets/buttons/app_icon_button.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('AppButton', () {
    for (final variant in AppButtonVariant.values) {
      for (final size in AppButtonSize.values) {
        testWidgets('renders $variant/$size and fires onPressed', (
          tester,
        ) async {
          var taps = 0;
          await pumpApp(
            tester,
            AppButton(
              label: 'Continue',
              variant: variant,
              size: size,
              onPressed: () => taps++,
            ),
          );
          expect(find.text('Continue'), findsOneWidget);
          await tester.tap(find.text('Continue'));
          expect(taps, 1);
        });
      }
    }

    testWidgets('null onPressed disables the button', (tester) async {
      await pumpApp(tester, const AppButton(label: 'Save', onPressed: null));
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('isLoading keeps the label width and blocks taps', (
      tester,
    ) async {
      var taps = 0;
      await pumpApp(
        tester,
        AppButton(label: 'Save changes', onPressed: () => taps++),
      );
      final idleWidth = tester.getSize(find.byType(FilledButton)).width;

      await pumpApp(
        tester,
        AppButton(
          label: 'Save changes',
          onPressed: () => taps++,
          isLoading: true,
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.getSize(find.byType(FilledButton)).width, idleWidth);
      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      expect(taps, 0);
    });

    testWidgets('loading spinner has a localized accessible label', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();

      await pumpApp(
        tester,
        const AppButton(label: 'Save', onPressed: null, isLoading: true),
      );
      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('fullWidth fills the available width', (tester) async {
      await pumpApp(
        tester,
        AppButton(label: 'Next', onPressed: () {}, fullWidth: true),
      );
      expect(
        tester.getSize(find.byType(FilledButton)).width,
        defaultTestSize.width,
      );
    });

    testWidgets('leading icon is on the start side, also in RTL', (
      tester,
    ) async {
      await pumpApp(
        tester,
        locale: const Locale('ar'),
        AppButton(
          label: 'Next',
          onPressed: () {},
          icon: Icons.add,
          trailingIcon: Icons.arrow_forward,
        ),
      );
      final leading = tester.getCenter(find.byIcon(Icons.add)).dx;
      final trailing = tester.getCenter(find.byIcon(Icons.arrow_forward)).dx;
      expect(leading, greaterThan(trailing), reason: 'RTL: start is right');
    });

    testWidgets('wraps without overflow at text scale 2.0 in RTL', (
      tester,
    ) async {
      await pumpApp(
        tester,
        locale: const Locale('ar'),
        textScale: 2,
        size: const Size(360, 640),
        AppButton(
          label: 'A very long label that must wrap instead of overflowing',
          onPressed: () {},
          size: AppButtonSize.sm,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('AppIconButton', () {
    for (final variant in AppIconButtonVariant.values) {
      testWidgets('renders $variant with tooltip and fires onPressed', (
        tester,
      ) async {
        var taps = 0;
        await pumpApp(
          tester,
          AppIconButton(
            icon: Icons.favorite,
            tooltip: 'Like',
            variant: variant,
            onPressed: () => taps++,
          ),
        );
        expect(find.byTooltip('Like'), findsOneWidget);
        await tester.tap(find.byIcon(Icons.favorite));
        expect(taps, 1);
      });
    }

    testWidgets('shows the badge overlay', (tester) async {
      await pumpApp(
        tester,
        AppIconButton(
          icon: Icons.notifications,
          tooltip: 'Notifications',
          onPressed: () {},
          badge: const Text('3'),
        ),
      );
      expect(find.text('3'), findsOneWidget);
    });
  });

  group('AppFab', () {
    testWidgets('is a plain FAB with a tooltip when no label is given', (
      tester,
    ) async {
      await pumpApp(
        tester,
        AppFab(icon: Icons.add, tooltip: 'Add', onPressed: () {}),
      );
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byTooltip('Add'), findsOneWidget);
    });

    testWidgets('shows the label when extended', (tester) async {
      await pumpApp(
        tester,
        AppFab(icon: Icons.add, tooltip: 'Add', label: 'New', onPressed: () {}),
      );
      expect(find.text('New'), findsOneWidget);
    });
  });
}

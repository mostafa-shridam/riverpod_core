import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:riverpod_core/design_system/widgets/feedback/app_status_type.dart';
import 'package:riverpod_core/design_system/widgets/feedback/banner/app_banner.dart';
import 'package:riverpod_core/design_system/widgets/feedback/progress/app_progress_bar.dart';
import 'package:riverpod_core/design_system/widgets/feedback/progress/app_progress_indicator.dart';
import 'package:riverpod_core/design_system/widgets/feedback/tooltip/app_tooltip.dart';
import '../dialogs/overlay_test_host.dart';

void main() {
  setUpAll(setUpOverlayTests);

  Widget page(Widget child) => Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  );

  group('AppBanner', () {
    for (final type in AppStatusType.values) {
      testWidgets('${type.name} shows its icon on its container color', (
        tester,
      ) async {
        await pumpOverlayHost(
          tester,
          page(AppBanner(message: 'msg', type: type)),
        );
        expect(find.byIcon(type.icon), findsOneWidget);
        final material = tester.widget<Material>(
          find
              .descendant(
                of: find.byType(AppBanner),
                matching: find.byType(Material),
              )
              .first,
        );
        expect(
          material.color,
          type.colorsOf(tester.element(find.byType(AppBanner))).container,
        );
      });
    }

    testWidgets('action and dismiss callbacks fire', (tester) async {
      var acted = 0;
      var dismissed = 0;
      await pumpOverlayHost(
        tester,
        page(
          AppBanner(
            title: 'Heads up',
            message: 'Storage is almost full',
            type: AppStatusType.warning,
            actionLabel: 'Manage',
            onAction: () => acted++,
            onDismiss: () => dismissed++,
          ),
        ),
      );
      expect(find.text('Heads up'), findsOneWidget);
      await tester.tap(find.text('Manage'));
      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(acted, 1);
      expect(dismissed, 1);
    });

    testWidgets('no action or close button unless asked', (tester) async {
      await pumpOverlayHost(tester, page(const AppBanner(message: 'plain')));
      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('dismiss tooltip is localized', (tester) async {
      await pumpOverlayHost(
        tester,
        page(AppBanner(message: 'm', onDismiss: () {})),
        locale: const Locale('ar'),
      );
      expect(find.byTooltip('إغلاق'), findsOneWidget);
    });

    testWidgets('RTL + 2.0 text scale with action does not overflow', (
      tester,
    ) async {
      await pumpOverlayHost(
        tester,
        page(
          AppBanner(
            title: 'تنبيه مهم جدًا',
            message: 'مساحة التخزين لديك على وشك الامتلاء بالكامل',
            type: AppStatusType.error,
            actionLabel: 'إدارة المساحة',
            onAction: () {},
            onDismiss: () {},
          ),
        ),
        locale: const Locale('ar'),
        textScale: 2.0,
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getCenter(find.byIcon(Icons.error_rounded)).dx,
        greaterThan(phoneSize.width / 2),
      );
    });
  });

  group('AppProgressBar', () {
    testWidgets('determinate value, label and localized percent', (
      tester,
    ) async {
      await pumpOverlayHost(
        tester,
        page(
          const AppProgressBar(
            value: 0.45,
            label: 'Uploading',
            showPercent: true,
          ),
        ),
      );
      expect(find.text('Uploading'), findsOneWidget);
      expect(find.text('45%'), findsOneWidget);
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, 0.45);
    });

    testWidgets('percent follows the Arabic number format in ar', (
      tester,
    ) async {
      await pumpOverlayHost(
        tester,
        page(const AppProgressBar(value: 0.5, showPercent: true)),
        locale: const Locale('ar'),
      );
      expect(
        find.text(NumberFormat.percentPattern('ar').format(0.5)),
        findsOneWidget,
      );
    });

    testWidgets('indeterminate has no value and no percent', (tester) async {
      await pumpOverlayHost(
        tester,
        page(const AppProgressBar(showPercent: true)),
        endless: true,
      );
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, isNull);
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('announces progress with a value', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpOverlayHost(tester, page(const AppProgressBar(value: 0.25)));
      expect(
        tester.getSemantics(find.byType(AppProgressBar)),
        matchesSemantics(label: 'Progress', value: '25%'),
      );
      handle.dispose();
    });

    testWidgets('2.0 text scale does not overflow', (tester) async {
      await pumpOverlayHost(
        tester,
        page(
          const AppProgressBar(
            value: 0.9,
            label: 'A long label here',
            showPercent: true,
          ),
        ),
        textScale: 2.0,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('AppProgressIndicator', () {
    testWidgets('determinate keeps its value', (tester) async {
      await pumpOverlayHost(
        tester,
        page(const AppProgressIndicator(value: 0.7)),
      );
      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, 0.7);
    });

    testWidgets('sizes grow sm < md < lg', (tester) async {
      final sizes = <AppProgressSize, double>{};
      for (final size in AppProgressSize.values) {
        await pumpOverlayHost(
          tester,
          page(AppProgressIndicator(value: 0.5, size: size)),
        );
        sizes[size] = tester
            .getSize(find.byType(CircularProgressIndicator))
            .width;
      }
      expect(sizes[AppProgressSize.sm]!, lessThan(sizes[AppProgressSize.md]!));
      expect(sizes[AppProgressSize.md]!, lessThan(sizes[AppProgressSize.lg]!));
    });

    testWidgets('indeterminate spins', (tester) async {
      await pumpOverlayHost(
        tester,
        page(const AppProgressIndicator()),
        endless: true,
      );
      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, isNull);
    });
  });

  group('AppTooltip', () {
    testWidgets('long press shows the message', (tester) async {
      await pumpOverlayHost(
        tester,
        page(
          const AppTooltip(
            message: 'More info',
            child: Icon(Icons.info_outline, size: 48),
          ),
        ),
      );
      expect(find.text('More info'), findsNothing);
      await tester.longPress(find.byIcon(Icons.info_outline));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('More info'), findsOneWidget);
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(find.text('More info'), findsNothing);
    });

    testWidgets('uses the inverse surface and the sm radius', (tester) async {
      await pumpOverlayHost(
        tester,
        page(
          const AppTooltip(
            message: 'Styled',
            child: Icon(Icons.info_outline, size: 48),
          ),
        ),
      );
      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      final decoration = tooltip.decoration! as BoxDecoration;
      final scheme = Theme.of(tester.element(find.byType(Tooltip))).colorScheme;
      expect(decoration.color, scheme.inverseSurface);
      expect(decoration.borderRadius, BorderRadius.circular(8));
    });
  });
}

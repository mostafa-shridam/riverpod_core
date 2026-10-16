import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:riverpod_core/design_system/widgets/bottom_sheets/app_bottom_sheet.dart';
import 'package:riverpod_core/design_system/widgets/bottom_sheets/app_sheet_frame.dart';
import '../dialogs/overlay_test_host.dart';

void main() {
  setUpAll(setUpOverlayTests);

  Future<void> open(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    Size size = phoneSize,
    double textScale = 1.0,
    String title = 'Sheet title',
    bool showClose = true,
    bool isDismissible = true,
    Widget? footer,
    ValueChanged<Object?>? onResult,
  }) async {
    await pumpOverlayHost(
      tester,
      OpenerPage(
        onOpen: (context) async {
          final result = await showAppBottomSheet<String>(
            context: context,
            title: title,
            showCloseButton: showClose,
            isDismissible: isDismissible,
            footer: footer,
            builder: (sheetContext) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Body content'),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop('picked'),
                  child: const Text('pick'),
                ),
              ],
            ),
          );
          onResult?.call(result);
        },
      ),
      locale: locale,
      size: size,
      textScale: textScale,
    );
    await tapOpen(tester);
  }

  testWidgets('opens with title and body, returns the popped value', (
    tester,
  ) async {
    Object? result = 'unset';
    await open(tester, onResult: (r) => result = r);
    expect(find.text('Sheet title'), findsOneWidget);
    expect(find.text('Body content'), findsOneWidget);

    await tester.tap(find.text('pick'));
    await tester.pumpAndSettle();
    expect(find.text('Body content'), findsNothing);
    expect(result, 'picked');
  });

  testWidgets('close button dismisses and returns null', (tester) async {
    Object? result = 'unset';
    await open(tester, onResult: (r) => result = r);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Body content'), findsNothing);
    expect(result, isNull);
  });

  testWidgets('tapping the scrim dismisses when isDismissible', (tester) async {
    await open(tester);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(find.text('Body content'), findsNothing);
  });

  testWidgets('tapping the scrim does nothing when not dismissible', (
    tester,
  ) async {
    await open(tester, isDismissible: false);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(find.text('Body content'), findsOneWidget);
  });

  testWidgets('scrim uses the themed scrim color at 40%', (tester) async {
    await open(tester);
    final barrier = tester.widget<ModalBarrier>(find.byType(ModalBarrier).last);
    final scheme = Theme.of(
      tester.element(find.text('Body content')),
    ).colorScheme;
    expect(barrier.color, scheme.scrim.withValues(alpha: 0.4));
  });

  testWidgets('surface has xl rounded top corners', (tester) async {
    await open(tester);
    final material = tester.widget<Material>(
      find
          .ancestor(
            of: find.text('Body content'),
            matching: find.byType(Material),
          )
          .first,
    );
    final shape = material.shape! as RoundedRectangleBorder;
    expect(
      shape.borderRadius,
      const BorderRadius.vertical(top: Radius.circular(24)),
    );
  });

  testWidgets('width is capped at 560 on tablets', (tester) async {
    await open(tester, size: tabletSize);
    final width = tester.getSize(find.byType(AppSheetFrame)).width;
    expect(width, 560);
  });

  testWidgets('phone sheet uses the full width', (tester) async {
    await open(tester);
    expect(tester.getSize(find.byType(AppSheetFrame)).width, phoneSize.width);
  });

  testWidgets('sticky footer stays above the keyboard', (tester) async {
    await open(tester, footer: const Text('footer'));
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    final footerBottom = tester.getBottomLeft(find.text('footer')).dy;
    expect(footerBottom, lessThanOrEqualTo(phoneSize.height - 300));
  });

  testWidgets('RTL aligns the title to the right edge', (tester) async {
    await open(tester, locale: const Locale('ar'), title: 'عنوان');
    final right = tester.getTopRight(find.text('عنوان')).dx;
    expect(right, greaterThan(phoneSize.width / 2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('announces itself as a named route', (tester) async {
    final handle = tester.ensureSemantics();
    await open(tester);
    expect(tester.getSemantics(find.text('Body content')), isNotNull);
    expect(find.bySemanticsLabel('Sheet title'), findsWidgets);
    handle.dispose();
  });

  testWidgets('survives text scale 2.0 with a long title', (tester) async {
    await open(
      tester,
      textScale: 2.0,
      title: 'A fairly long sheet title that must wrap',
      footer: const Text('footer'),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Body content'), findsOneWidget);
  });

  testWidgets('draggable variant scrolls its list', (tester) async {
    await pumpOverlayHost(
      tester,
      OpenerPage(
        onOpen: (context) => showAppDraggableSheet<void>(
          context: context,
          title: 'Draggable',
          builder: (_, controller) => ListView.builder(
            controller: controller,
            itemCount: 60,
            itemBuilder: (_, i) => ListTile(title: Text('row $i')),
          ),
        ),
      ),
    );
    await tapOpen(tester);
    expect(find.text('row 0'), findsOneWidget);
    expect(find.text('row 59'), findsNothing);
    // The first drag expands the sheet, the next ones scroll the list.
    for (var i = 0; i < 3; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();
    }
    expect(find.text('row 0'), findsNothing);
  });

  group('goldens', () {
    for (final (name, locale, dark) in goldenVariants) {
      testWidgets('base sheet $name', (tester) async {
        await pumpOverlayHost(
          tester,
          OpenerPage(
            onOpen: (context) => showAppBottomSheet<void>(
              context: context,
              title: locale.languageCode == 'ar' ? 'عنوان' : 'Sheet title',
              showCloseButton: true,
              builder: (_) => const Text('Body content'),
            ),
          ),
          locale: locale,
          dark: dark,
        );
        await tapOpen(tester);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../../../goldens/bottom_sheets/base_$name.png'),
        );
      });
    }
  });
}

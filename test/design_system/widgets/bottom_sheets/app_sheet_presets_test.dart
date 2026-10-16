import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:riverpod_core/design_system/widgets/bottom_sheets/app_action_sheet.dart';
import 'package:riverpod_core/design_system/widgets/bottom_sheets/app_form_sheet.dart';
import 'package:riverpod_core/design_system/widgets/bottom_sheets/app_selection_sheet.dart';
import '../dialogs/overlay_test_host.dart';

const _actions = [
  AppSheetAction<String>(label: 'Edit', value: 'edit', icon: Icons.edit),
  AppSheetAction<String>(label: 'Share', value: 'share', icon: Icons.share),
  AppSheetAction<String>(
    label: 'Delete',
    value: 'delete',
    icon: Icons.delete,
    isDestructive: true,
  ),
];

const _options = [
  AppSelectionOption<int>(value: 1, label: 'Apple'),
  AppSelectionOption<int>(value: 2, label: 'Banana'),
  AppSelectionOption<int>(value: 3, label: 'Cherry'),
];

void main() {
  setUpAll(setUpOverlayTests);

  Future<void> openWith(
    WidgetTester tester,
    void Function(BuildContext) onOpen, {
    Locale locale = const Locale('en'),
    bool dark = false,
    double textScale = 1.0,
  }) async {
    await pumpOverlayHost(
      tester,
      OpenerPage(onOpen: onOpen),
      locale: locale,
      dark: dark,
      textScale: textScale,
    );
    await tapOpen(tester);
  }

  group('AppActionSheet', () {
    void openAction(BuildContext c, ValueChanged<String?> done) {
      AppActionSheet.show<String>(
        context: c,
        title: 'Actions',
        message: 'Pick one',
        actions: _actions,
      ).then(done);
    }

    testWidgets('returns the tapped action value', (tester) async {
      String? result;
      await openWith(tester, (c) => openAction(c, (v) => result = v));
      expect(find.text('Pick one'), findsOneWidget);
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();
      expect(result, 'share');
    });

    testWidgets('destructive action is error colored and separated', (
      tester,
    ) async {
      await openWith(tester, (c) => openAction(c, (_) {}));
      final scheme = Theme.of(tester.element(find.text('Delete'))).colorScheme;
      final icon = tester.widget<Icon>(find.byIcon(Icons.delete));
      expect(icon.color, scheme.error);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('cancel returns null', (tester) async {
      String? result = 'unset';
      await openWith(tester, (c) => openAction(c, (v) => result = v));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(find.text('Edit'), findsNothing);
    });

    testWidgets('cancel label is localized in Arabic', (tester) async {
      await openWith(
        tester,
        (c) => openAction(c, (_) {}),
        locale: const Locale('ar'),
      );
      expect(find.text('إلغاء'), findsOneWidget);
    });

    testWidgets('2.0 text scale does not overflow', (tester) async {
      await openWith(tester, (c) => openAction(c, (_) {}), textScale: 2.0);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppSelectionSheet', () {
    testWidgets('single choice pops immediately with the value', (
      tester,
    ) async {
      int? result;
      await openWith(
        tester,
        (c) => AppSelectionSheet.showSingle<int>(
          context: c,
          title: 'Fruit',
          options: _options,
          selected: 2,
        ).then((v) => result = v),
      );
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      await tester.tap(find.text('Cherry'));
      await tester.pumpAndSettle();
      expect(result, 3);
    });

    testWidgets('multi choice toggles and returns the list on done', (
      tester,
    ) async {
      List<int>? result;
      await openWith(
        tester,
        (c) => AppSelectionSheet.show<int>(
          context: c,
          title: 'Fruit',
          options: _options,
          selected: const [1],
          multiSelect: true,
        ).then((v) => result = v),
      );
      await tester.tap(find.text('Banana'));
      await tester.tap(find.text('Apple'));
      await tester.pump();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(result, [2]);
    });

    testWidgets('search filters and shows the empty message', (tester) async {
      await openWith(
        tester,
        (c) => AppSelectionSheet.show<int>(
          context: c,
          options: _options,
          searchable: true,
        ),
      );
      await tester.enterText(find.byType(TextField), 'ban');
      await tester.pump();
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();
      expect(find.text('No results'), findsOneWidget);
    });

    testWidgets('dismiss returns null', (tester) async {
      List<int>? result = [9];
      await openWith(
        tester,
        (c) => AppSelectionSheet.show<int>(
          context: c,
          options: _options,
        ).then((v) => result = v),
      );
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });
  });

  group('AppFormSheet', () {
    Future<void> openForm(
      WidgetTester tester, {
      required VoidCallback onPrimary,
      Locale locale = const Locale('en'),
      bool dark = false,
      double textScale = 1.0,
      ValueChanged<String?>? done,
    }) {
      return openWith(
        tester,
        (c) => AppFormSheet.show<String>(
          context: c,
          title: 'New item',
          primaryLabel: 'Save',
          content: (_) => const TextField(),
          onPrimary: (sheet) {
            onPrimary();
            Navigator.of(sheet).pop('saved');
          },
        ).then((v) => done?.call(v)),
        locale: locale,
        dark: dark,
        textScale: textScale,
      );
    }

    testWidgets('primary runs the callback and can pop a value', (
      tester,
    ) async {
      var called = 0;
      String? result;
      await openForm(
        tester,
        onPrimary: () => called++,
        done: (v) => result = v,
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(called, 1);
      expect(result, 'saved');
    });

    testWidgets('secondary closes with null', (tester) async {
      String? result = 'unset';
      await openForm(tester, onPrimary: () {}, done: (v) => result = v);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });

    testWidgets('footer sits above the keyboard', (tester) async {
      await openForm(tester, onPrimary: () {});
      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(
        tester.getBottomLeft(find.text('Save')).dy,
        lessThanOrEqualTo(phoneSize.height - 320),
      );
    });

    testWidgets('2.0 text scale does not overflow', (tester) async {
      await openForm(tester, onPrimary: () {}, textScale: 2.0);
      expect(tester.takeException(), isNull);
    });
  });

  group('goldens', () {
    for (final (name, locale, dark) in goldenVariants) {
      final ar = locale.languageCode == 'ar';

      testWidgets('action sheet $name', (tester) async {
        await openWith(
          tester,
          (c) => AppActionSheet.show<String>(
            context: c,
            title: ar ? 'الإجراءات' : 'Actions',
            actions: _actions,
          ),
          locale: locale,
          dark: dark,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../../../goldens/bottom_sheets/action_$name.png'),
        );
      });

      testWidgets('selection sheet $name', (tester) async {
        await openWith(
          tester,
          (c) => AppSelectionSheet.show<int>(
            context: c,
            title: ar ? 'اختر' : 'Choose',
            options: _options,
            selected: const [2],
            multiSelect: true,
            searchable: true,
          ),
          locale: locale,
          dark: dark,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            '../../../goldens/bottom_sheets/selection_$name.png',
          ),
        );
      });

      testWidgets('form sheet $name', (tester) async {
        await openWith(
          tester,
          (c) => AppFormSheet.show<void>(
            context: c,
            title: ar ? 'عنصر جديد' : 'New item',
            primaryLabel: ar ? 'حفظ' : 'Save',
            content: (_) => const TextField(),
            onPrimary: (_) {},
          ),
          locale: locale,
          dark: dark,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../../../goldens/bottom_sheets/form_$name.png'),
        );
      });
    }

    testWidgets('form sheet at text scale 2.0', (tester) async {
      await openWith(
        tester,
        (c) => AppFormSheet.show<void>(
          context: c,
          title: 'New item',
          primaryLabel: 'Save',
          content: (_) => const TextField(),
          onPrimary: (_) {},
        ),
        dark: true,
        textScale: 2.0,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../../goldens/bottom_sheets/form_scale2.png'),
      );
    });

    testWidgets('action sheet at text scale 2.0', (tester) async {
      await openWith(
        tester,
        (c) => AppActionSheet.show<String>(
          context: c,
          title: 'Actions',
          actions: _actions,
        ),
        locale: const Locale('ar'),
        textScale: 2.0,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../../goldens/bottom_sheets/action_scale2.png'),
      );
    });
  });
}

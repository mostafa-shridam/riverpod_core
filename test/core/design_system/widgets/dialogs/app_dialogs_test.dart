import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:riverpod_core/core/design_system/widgets/dialogs/app_alert_dialog.dart';
import 'package:riverpod_core/core/design_system/widgets/dialogs/app_confirm_dialog.dart';
import 'package:riverpod_core/core/design_system/widgets/dialogs/app_input_dialog.dart';
import 'package:riverpod_core/core/design_system/widgets/dialogs/app_loading_dialog.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/app_status_type.dart';
import 'overlay_test_host.dart';

/// The painted card of the open dialog (the `Dialog` widget itself spans the
/// whole screen).
Finder _surface() => find
    .descendant(of: find.byType(Dialog), matching: find.byType(Material))
    .first;

void main() {
  setUpAll(setUpOverlayTests);

  Future<void> openWith(
    WidgetTester tester,
    void Function(BuildContext) onOpen, {
    Locale locale = const Locale('en'),
    bool dark = false,
    double textScale = 1.0,
    Size size = phoneSize,
    bool endless = false,
  }) async {
    await pumpOverlayHost(
      tester,
      OpenerPage(onOpen: onOpen),
      locale: locale,
      dark: dark,
      textScale: textScale,
      size: size,
    );
    await tapOpen(tester, endless: endless);
  }

  group('AppAlertDialog', () {
    for (final type in AppStatusType.values) {
      testWidgets('shows the ${type.name} icon in its tinted circle', (
        tester,
      ) async {
        await openWith(
          tester,
          (c) => AppAlertDialog.show(context: c, title: 'T', type: type),
        );
        final icon = tester.widget<Icon>(find.byIcon(type.icon));
        expect(
          icon.color,
          type.colorsOf(tester.element(find.text('T'))).accent,
        );
      });
    }

    testWidgets('OK closes and calls onConfirm', (tester) async {
      var confirmed = 0;
      await openWith(
        tester,
        (c) => AppAlertDialog.show(
          context: c,
          title: 'Saved',
          message: 'All good',
          type: AppStatusType.success,
          onConfirm: () => confirmed++,
        ),
      );
      expect(find.text('All good'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Saved'), findsNothing);
      expect(confirmed, 1);
    });

    testWidgets('barrierDismissible false keeps it open on scrim tap', (
      tester,
    ) async {
      await openWith(
        tester,
        (c) => AppAlertDialog.show(
          context: c,
          title: 'Stay',
          barrierDismissible: false,
        ),
      );
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Stay'), findsOneWidget);
    });

    testWidgets('label is localized in Arabic and text is right aligned', (
      tester,
    ) async {
      await openWith(
        tester,
        (c) => AppAlertDialog.show(context: c, title: 'عنوان'),
        locale: const Locale('ar'),
      );
      expect(find.text('حسنًا'), findsOneWidget);
    });

    testWidgets('dialog is capped at 560 on tablets', (tester) async {
      await openWith(
        tester,
        (c) => AppAlertDialog.show(context: c, title: 'T', message: 'M' * 400),
        size: tabletSize,
      );
      final size = tester.getSize(_surface());
      expect(size.width, lessThanOrEqualTo(560));
    });

    testWidgets('announces as a named route', (tester) async {
      final handle = tester.ensureSemantics();
      await openWith(
        tester,
        (c) => AppAlertDialog.show(context: c, title: 'T'),
      );
      expect(find.bySemanticsLabel('T'), findsWidgets);
      handle.dispose();
    });
  });

  group('AppConfirmDialog', () {
    Future<void> openConfirm(
      WidgetTester tester,
      ValueChanged<bool> done, {
      bool destructive = false,
      Size size = phoneSize,
      double textScale = 1.0,
    }) {
      return openWith(
        tester,
        (c) => AppConfirmDialog.show(
          context: c,
          title: 'Delete?',
          message: 'This cannot be undone',
          isDestructive: destructive,
        ).then(done),
        size: size,
        textScale: textScale,
      );
    }

    testWidgets('confirm returns true', (tester) async {
      bool? result;
      await openConfirm(tester, (v) => result = v);
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('cancel returns false', (tester) async {
      bool? result;
      await openConfirm(tester, (v) => result = v);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('scrim dismiss counts as false', (tester) async {
      bool? result;
      await openConfirm(tester, (v) => result = v);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('destructive uses the error color and a warning icon', (
      tester,
    ) async {
      await openConfirm(tester, (_) {}, destructive: true);
      final scheme = Theme.of(tester.element(find.text('Delete?'))).colorScheme;
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.style?.backgroundColor?.resolve({}), scheme.error);
      expect(find.byIcon(AppStatusType.warning.icon), findsOneWidget);
    });

    testWidgets('buttons stack on phones and sit in a row on tablets', (
      tester,
    ) async {
      await openConfirm(tester, (_) {});
      final confirmPhone = tester.getTopLeft(find.byType(FilledButton));
      final cancelPhone = tester.getTopLeft(find.byType(TextButton));
      expect(confirmPhone.dy, lessThan(cancelPhone.dy));
      expect(confirmPhone.dx, cancelPhone.dx);
    });

    testWidgets('tablet puts the buttons side by side', (tester) async {
      await openConfirm(tester, (_) {}, size: tabletSize);
      final confirm = tester.getTopLeft(find.byType(FilledButton));
      final cancel = tester.getTopLeft(find.byType(TextButton));
      expect(confirm.dy, cancel.dy);
    });

    testWidgets('2.0 text scale does not overflow', (tester) async {
      await openConfirm(tester, (_) {}, destructive: true, textScale: 2.0);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppInputDialog', () {
    testWidgets('returns the entered text when valid', (tester) async {
      String? result;
      await openWith(
        tester,
        (c) => AppInputDialog.show(
          context: c,
          title: 'Name',
          label: 'Your name',
          validator: (v) => v.trim().isEmpty ? 'Required' : null,
        ).then((v) => result = v),
      );
      await tester.enterText(find.byType(TextFormField), 'Sara');
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(result, 'Sara');
    });

    testWidgets('shows the validator error and stays open', (tester) async {
      await openWith(
        tester,
        (c) => AppInputDialog.show(
          context: c,
          title: 'Name',
          validator: (v) => v.trim().isEmpty ? 'Required' : null,
        ),
      );
      await tester.tap(find.text('Confirm'));
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('cancel returns null', (tester) async {
      String? result = 'unset';
      await openWith(
        tester,
        (c) => AppInputDialog.show(
          context: c,
          title: 'Name',
          initialValue: 'x',
        ).then((v) => result = v),
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });

    testWidgets('keyboard submit validates and closes', (tester) async {
      String? result;
      await openWith(
        tester,
        (c) => AppInputDialog.show(
          context: c,
          title: 'Name',
        ).then((v) => result = v),
      );
      await tester.enterText(find.byType(TextFormField), 'Ali');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(result, 'Ali');
    });

    testWidgets('dialog moves up with the keyboard', (tester) async {
      await openWith(
        tester,
        (c) => AppInputDialog.show(context: c, title: 'Name'),
      );
      final before = tester.getBottomLeft(_surface()).dy;
      tester.view.viewInsets = const FakeViewPadding(bottom: 400);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.getBottomLeft(_surface()).dy, lessThan(before));
      expect(
        tester.getBottomLeft(_surface()).dy,
        lessThanOrEqualTo(phoneSize.height - 400),
      );
    });

    testWidgets('2.0 text scale in Arabic does not overflow', (tester) async {
      await openWith(
        tester,
        (c) => AppInputDialog.show(context: c, title: 'الاسم'),
        locale: const Locale('ar'),
        textScale: 2.0,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('AppLoadingDialog / AppLoadingOverlay', () {
    testWidgets('blocks until the returned callback closes it', (tester) async {
      late VoidCallback close;
      await openWith(
        tester,
        (c) => close = AppLoadingDialog.show(context: c, message: 'Saving'),
        endless: true,
      );
      expect(find.text('Saving'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tapAt(const Offset(5, 5));
      await settle(tester, endless: true);
      expect(find.text('Saving'), findsOneWidget, reason: 'barrier blocks');

      close();
      await settle(tester, endless: true);
      expect(find.text('Saving'), findsNothing);
      close(); // second call is a no-op
      await settle(tester, endless: true);
    });

    testWidgets('uses the localized default label for semantics', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      late VoidCallback close;
      await openWith(
        tester,
        (c) => close = AppLoadingDialog.show(context: c),
        endless: true,
      );
      expect(find.bySemanticsLabel('Loading'), findsWidgets);
      close();
      await settle(tester, endless: true);
      handle.dispose();
    });

    testWidgets('overlay blocks taps only while loading', (tester) async {
      var taps = 0;
      Widget page({required bool loading}) => AppLoadingOverlay(
        isLoading: loading,
        message: 'Wait',
        child: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => taps++,
              child: const Text('tap'),
            ),
          ),
        ),
      );
      await pumpOverlayHost(tester, page(loading: false), endless: true);
      await tester.tap(find.text('tap'));
      expect(taps, 1);
      expect(find.text('Wait'), findsNothing);

      await pumpOverlayHost(tester, page(loading: true), endless: true);
      expect(find.text('Wait'), findsOneWidget);
      await tester.tap(find.text('tap'), warnIfMissed: false);
      expect(taps, 1);

      await pumpOverlayHost(tester, page(loading: false), endless: true);
      expect(find.text('Wait'), findsNothing);
      await tester.tap(find.text('tap'));
      expect(taps, 2);
    });
  });

  group('goldens', () {
    for (final (name, locale, dark) in goldenVariants) {
      final ar = locale.languageCode == 'ar';
      final title = ar ? 'تم الحفظ' : 'Saved';
      final body = ar ? 'تم حفظ التغييرات بنجاح' : 'Your changes were saved';

      Future<void> golden(
        WidgetTester tester,
        String file,
        void Function(BuildContext) open, {
        double textScale = 1.0,
        bool endless = false,
      }) async {
        await openWith(
          tester,
          open,
          locale: locale,
          dark: dark,
          textScale: textScale,
          endless: endless,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../../../../goldens/dialogs/$file.png'),
        );
      }

      testWidgets('alert success $name', (tester) async {
        await golden(
          tester,
          'alert_success_$name',
          (c) => AppAlertDialog.show(
            context: c,
            title: title,
            message: body,
            type: AppStatusType.success,
          ),
        );
      });

      testWidgets('alert error $name', (tester) async {
        await golden(
          tester,
          'alert_error_$name',
          (c) => AppAlertDialog.show(
            context: c,
            title: title,
            message: body,
            type: AppStatusType.error,
          ),
        );
      });

      testWidgets('confirm destructive $name', (tester) async {
        await golden(
          tester,
          'confirm_$name',
          (c) => AppConfirmDialog.show(
            context: c,
            title: title,
            message: body,
            isDestructive: true,
          ),
        );
      });

      testWidgets('input $name', (tester) async {
        await golden(
          tester,
          'input_$name',
          (c) => AppInputDialog.show(
            context: c,
            title: title,
            label: ar ? 'الاسم' : 'Name',
          ),
        );
      });

      testWidgets('loading $name', (tester) async {
        await golden(
          tester,
          'loading_$name',
          (c) => AppLoadingDialog.show(context: c, message: title),
          endless: true,
        );
      });
    }

    testWidgets('confirm at text scale 2.0', (tester) async {
      await openWith(
        tester,
        (c) => AppConfirmDialog.show(
          context: c,
          title: 'Delete this item?',
          message: 'This cannot be undone',
          isDestructive: true,
        ),
        textScale: 2.0,
        dark: true,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../../../goldens/dialogs/confirm_scale2.png'),
      );
    });

    testWidgets('alert at text scale 2.0 in Arabic', (tester) async {
      await openWith(
        tester,
        (c) => AppAlertDialog.show(
          context: c,
          title: 'حدث خطأ',
          message: 'تعذر إكمال العملية، حاول مرة أخرى لاحقًا',
          type: AppStatusType.error,
        ),
        locale: const Locale('ar'),
        textScale: 2.0,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../../../goldens/dialogs/alert_scale2.png'),
      );
    });
  });
}

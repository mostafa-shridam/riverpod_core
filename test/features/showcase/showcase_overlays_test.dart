import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/bottom_sheets/app_action_sheet.dart';
import 'package:riverpod_core/core/design_system/widgets/bottom_sheets/app_selection_sheet.dart';
import 'package:riverpod_core/core/design_system/widgets/bottom_sheets/app_sheet_frame.dart';
import 'package:riverpod_core/core/design_system/widgets/dialogs/app_alert_dialog.dart';
import 'package:riverpod_core/core/design_system/widgets/dialogs/app_confirm_dialog.dart';
import 'package:riverpod_core/core/design_system/widgets/dialogs/app_input_dialog.dart';
import 'package:riverpod_core/core/design_system/widgets/dialogs/app_loading_dialog.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/app_status_type.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/banner/app_banner.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/snackbar/app_toast.dart';

import 'showcase_test_support.dart';

/// Opens the overlay behind [key] and returns after it settled.
Future<void> _open(WidgetTester tester, String key) async {
  await pumpShowcase(tester);
  await scrollTo(tester, find.byKey(const ValueKey('showcase-overlays')));
  await scrollTo(tester, find.byKey(ValueKey(key)));
  await tester.tap(find.byKey(ValueKey(key)));
  await settle(tester);
}

void main() {
  final cases = <String, Type>{
    'open-modal-sheet': AppSheetFrame,
    'open-action-sheet': AppActionSheet<String>,
    'open-selection-sheet': AppSelectionSheet<int>,
    'open-form-sheet': AppSheetFrame,
    'open-confirm': AppConfirmDialog,
    'open-confirm-destructive': AppConfirmDialog,
    'open-input-dialog': AppInputDialog,
  };

  cases.forEach((key, type) {
    testWidgets('$key opens its overlay', (tester) async {
      await _open(tester, key);
      expect(find.byType(type), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  for (final status in AppStatusType.values) {
    testWidgets('alert ${status.name} opens an AppAlertDialog', (tester) async {
      await _open(tester, 'open-alert-${status.name}');
      expect(find.byType(AppAlertDialog), findsOneWidget);
      final dialog = tester.widget<AppAlertDialog>(find.byType(AppAlertDialog));
      expect(dialog.type, status);
    });

    testWidgets('snackbar ${status.name} shows a toast message', (
      tester,
    ) async {
      await _open(tester, 'open-snackbar-${status.name}');
      expect(find.byType(AppToast), findsOneWidget);
      final toast = tester.widget<AppToast>(find.byType(AppToast));
      expect(toast.message.type, status);
      await tester.pump(const Duration(seconds: 10));
      await settle(tester);
    });
  }

  for (final key in ['open-toast-top', 'open-toast-bottom']) {
    testWidgets('$key shows a toast', (tester) async {
      await _open(tester, key);
      expect(find.byType(AppToast), findsOneWidget);
      await tester.pump(const Duration(seconds: 10));
      await settle(tester);
    });
  }

  testWidgets('loading overlay shows, then closes by itself', (tester) async {
    await _open(tester, 'open-loading-overlay');
    expect(find.byType(AppLoadingDialog), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await settle(tester);
    expect(find.byType(AppLoadingDialog), findsNothing);
  });

  testWidgets('banner button shows and hides the banner', (tester) async {
    await _open(tester, 'toggle-banner');
    expect(find.byType(AppBanner), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('toggle-banner')));
    await settle(tester);
    expect(find.byType(AppBanner), findsNothing);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:riverpod_core/core/design_system/widgets/feedback/app_status_type.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/snackbar/app_message.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/snackbar/app_messenger.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/snackbar/app_snackbar.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/snackbar/app_toast.dart';
import '../dialogs/overlay_test_host.dart';

void main() {
  setUpAll(setUpOverlayTests);

  late ProviderContainer container;
  late BuildContext pageContext;

  AppMessenger messenger() => container.read(appMessengerProvider);

  Future<void> pumpPage(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    bool dark = false,
    double textScale = 1.0,
    Size size = phoneSize,
    bool wireKey = true,
  }) async {
    container = ProviderContainer();
    addTearDown(container.dispose);
    await pumpOverlayHost(
      tester,
      Builder(
        builder: (context) {
          pageContext = context;
          return const Scaffold(body: Center(child: Text('page')));
        },
      ),
      locale: locale,
      dark: dark,
      textScale: textScale,
      size: size,
      container: container,
      messengerKey: wireKey ? messenger().key : null,
    );
  }

  Future<void> pumpFor(WidgetTester tester, Duration d) async {
    await tester.pump();
    await tester.pump(d);
    await tester.pump(const Duration(seconds: 1));
    // A toast inserted by the last frame is built on the next one.
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('shows a snackbar and auto-dismisses it', (tester) async {
    await pumpPage(tester);
    showAppSnackbar(pageContext, message: 'Saved', type: AppStatusType.success);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Saved'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(messenger().isShowing, isTrue);

    await pumpFor(tester, const Duration(seconds: 5));
    expect(find.text('Saved'), findsNothing);
    expect(messenger().isShowing, isFalse);
  });

  testWidgets('each type has its own icon and tint', (tester) async {
    await pumpPage(tester);
    for (final type in AppStatusType.values) {
      showAppSnackbar(pageContext, message: type.name, type: type);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byIcon(type.icon), findsOneWidget);
      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(AppToast),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, type.colorsOf(pageContext).container);
      messenger().hideCurrent();
      await pumpFor(tester, const Duration(milliseconds: 300));
    }
  });

  testWidgets('shows one toast at a time and queues the rest in order', (
    tester,
  ) async {
    await pumpPage(tester);
    showAppSnackbar(pageContext, message: 'first');
    showAppSnackbar(pageContext, message: 'second');
    showAppToast(pageContext, message: 'third');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsNothing);
    expect(find.byType(AppToast), findsOneWidget);
    expect(messenger().queuedCount, 2);

    messenger().hideCurrent();
    await pumpFor(tester, const Duration(milliseconds: 300));
    expect(find.text('first'), findsNothing);
    expect(find.text('second'), findsOneWidget);
    expect(messenger().queuedCount, 1);

    await pumpFor(tester, const Duration(seconds: 5));
    expect(find.text('third'), findsOneWidget);
    await pumpFor(tester, const Duration(seconds: 5));
    expect(find.byType(AppToast), findsNothing);
    expect(messenger().queuedCount, 0);
  });

  testWidgets('replaceCurrent drops the queue and shows the new one next', (
    tester,
  ) async {
    await pumpPage(tester);
    showAppSnackbar(pageContext, message: 'a');
    showAppSnackbar(pageContext, message: 'b');
    await tester.pump();
    showAppSnackbar(pageContext, message: 'urgent', replaceCurrent: true);
    await pumpFor(tester, const Duration(milliseconds: 300));
    expect(find.text('urgent'), findsOneWidget);
    expect(find.text('b'), findsNothing);
    messenger().clear();
    await pumpFor(tester, const Duration(milliseconds: 300));
  });

  testWidgets('swipe dismisses and lets the next one in', (tester) async {
    await pumpPage(tester);
    showAppSnackbar(pageContext, message: 'swipe me');
    showAppSnackbar(pageContext, message: 'next');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.fling(find.text('swipe me'), const Offset(600, 0), 2000);
    await tester.pumpAndSettle();
    expect(find.text('swipe me'), findsNothing);
    expect(find.text('next'), findsOneWidget);
    messenger().clear();
    await pumpFor(tester, const Duration(milliseconds: 300));
  });

  testWidgets('action runs its callback and dismisses', (tester) async {
    await pumpPage(tester);
    var undone = 0;
    showAppSnackbar(
      pageContext,
      message: 'Deleted',
      actionLabel: 'Undo',
      onAction: () => undone++,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Undo'));
    await pumpFor(tester, const Duration(milliseconds: 300));
    expect(undone, 1);
    expect(find.text('Deleted'), findsNothing);
  });

  testWidgets('top and bottom positions', (tester) async {
    await pumpPage(tester);
    showAppToast(pageContext, message: 'on top');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester.getTopLeft(find.byType(AppToast)).dy,
      lessThan(phoneSize.height / 4),
    );
    messenger().hideCurrent();
    await pumpFor(tester, const Duration(milliseconds: 300));

    showAppSnackbar(pageContext, message: 'at bottom');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester.getBottomLeft(find.byType(AppToast)).dy,
      greaterThan(phoneSize.height * 3 / 4),
    );
    messenger().clear();
    await pumpFor(tester, const Duration(milliseconds: 300));
  });

  testWidgets('non-widget code can show a message through the root key', (
    tester,
  ) async {
    await pumpPage(tester);
    // No BuildContext hint: the overlay is found through the messenger key.
    messenger().show(const AppMessage(message: 'from a provider'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('from a provider'), findsOneWidget);
    messenger().clear();
    await pumpFor(tester, const Duration(milliseconds: 300));
  });

  testWidgets('keeps the message queued until an overlay exists', (
    tester,
  ) async {
    container = ProviderContainer();
    addTearDown(container.dispose);
    messenger().show(const AppMessage(message: 'early'));
    expect(messenger().queuedCount, 1);
    expect(messenger().isShowing, isFalse);
  });

  testWidgets('floats above the keyboard', (tester) async {
    await pumpPage(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    showAppSnackbar(pageContext, message: 'typing');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester.getBottomLeft(find.byType(AppToast)).dy,
      lessThanOrEqualTo(phoneSize.height - 300),
    );
    messenger().clear();
    await pumpFor(tester, const Duration(milliseconds: 300));
  });

  testWidgets('width is capped at 560 on tablets', (tester) async {
    await pumpPage(tester, size: tabletSize);
    showAppSnackbar(pageContext, message: 'long ' * 80);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getSize(find.byType(AppToast)).width, 560);
    messenger().clear();
    await pumpFor(tester, const Duration(milliseconds: 300));
  });

  testWidgets('RTL Arabic with 2.0 text scale and action does not overflow', (
    tester,
  ) async {
    await pumpPage(tester, locale: const Locale('ar'), textScale: 2.0);
    showAppSnackbar(
      pageContext,
      message: 'تم حذف العنصر بنجاح من القائمة الخاصة بك',
      type: AppStatusType.warning,
      actionLabel: 'تراجع',
      onAction: () {},
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    // Icon sits at the start edge, i.e. the right side in RTL.
    expect(
      tester.getCenter(find.byIcon(Icons.warning_amber_rounded)).dx,
      greaterThan(phoneSize.width / 2),
    );
    messenger().clear();
    await pumpFor(tester, const Duration(milliseconds: 300));
  });

  testWidgets('is a live region with a localized type label', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpPage(tester);
    showAppSnackbar(pageContext, message: 'Boom', type: AppStatusType.error);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.bySemanticsLabel('Error: Boom'), findsOneWidget);
    messenger().clear();
    await pumpFor(tester, const Duration(milliseconds: 300));
    handle.dispose();
  });

  testWidgets('disposing the messenger removes a visible toast', (
    tester,
  ) async {
    await pumpPage(tester);
    showAppSnackbar(pageContext, message: 'bye');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    messenger().dispose();
    await tester.pump();
    expect(find.byType(AppToast), findsNothing);
  });
}

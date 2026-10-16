import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/features/onboarding/presentation/pages/onboarding_page.dart';

import '../../helpers/helpers.dart';
import '../auth/auth_harness.dart';

Future<PrefsStorage> _pumpOnboarding(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
}) async {
  final prefs = await tester.runAsync(() => fakePrefsStorage());
  await pumpAuthPage(
    tester,
    const OnboardingPage(),
    locale: locale,
    overrides: [
      prefsStorageProvider.overrideWith((ref) => Future.value(prefs)),
    ],
  );
  return prefs!;
}

void main() {
  testWidgets('shows the first slide with skip and next', (tester) async {
    await _pumpOnboarding(tester);

    expect(find.byKey(const ValueKey('onboarding-page')), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('next moves to the next slide', (tester) async {
    final prefs = await _pumpOnboarding(tester);

    await tester.tap(find.widgetWithText(AppButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Keep track'), findsOneWidget);
    expect(prefs.onboardingSeen, isFalse, reason: 'not finished yet');
  });

  testWidgets('a swipe moves to the next slide too', (tester) async {
    await _pumpOnboarding(tester);

    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();

    expect(find.text('Keep track'), findsOneWidget);
  });

  testWidgets('get started on the last slide stores the flag', (tester) async {
    final prefs = await _pumpOnboarding(tester);

    await tester.tap(find.widgetWithText(AppButton, 'Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Your account is safe'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);

    await tester.tap(find.widgetWithText(AppButton, 'Get started'));
    await tester.pumpAndSettle();

    expect(prefs.onboardingSeen, isTrue);
  });

  testWidgets('skip stores the flag from the first slide', (tester) async {
    final prefs = await _pumpOnboarding(tester);

    await tester.tap(find.widgetWithText(AppButton, 'Skip'));
    await tester.pumpAndSettle();

    expect(prefs.onboardingSeen, isTrue);
  });

  testWidgets('in Arabic the skip action sits at the start of the row', (
    tester,
  ) async {
    await _pumpOnboarding(tester, locale: const Locale('ar'));

    expect(
      Directionality.of(tester.element(find.byType(OnboardingPage))),
      TextDirection.rtl,
    );
    final skip = tester.getCenter(find.text('تخطي'));
    expect(skip.dx, lessThan(tester.getSize(find.byType(Scaffold)).width / 2));
  });
}

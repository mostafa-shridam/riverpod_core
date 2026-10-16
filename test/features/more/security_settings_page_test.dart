import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/async/error_state.dart';
import 'package:riverpod_core/core/design_system/widgets/async/skeleton_list.dart';
import 'package:riverpod_core/core/security/app_lock_controller.dart';
import 'package:riverpod_core/core/security/biometric_service.dart';
import 'package:riverpod_core/features/more/presentation/pages/security_settings_page.dart';

import '../../core/security/security_fakes.dart';
import '../../helpers/helpers.dart';

Future<void> pumpSecurityPage(
  WidgetTester tester, {
  required List<Override> overrides,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  double textScale = 1,
  Size size = defaultTestSize,
}) async {
  await pumpApp(
    tester,
    const SecuritySettingsPage(),
    overrides: overrides,
    locale: locale,
    themeMode: themeMode,
    textScale: textScale,
    size: size,
  );
  await tester.pumpAndSettle();
}

Finder get _switch => find.byType(Switch);

void main() {
  testWidgets('shows the app lock switch, off by default', (tester) async {
    await pumpSecurityPage(tester, overrides: await securityOverrides(tester));

    expect(find.text('Security'), findsOneWidget);
    expect(find.text('App lock'), findsOneWidget);
    expect(tester.widget<Switch>(_switch).value, isFalse);
    expect(tester.widget<Switch>(_switch).onChanged, isNotNull);
    expect(find.byKey(const ValueKey('security-unavailable')), findsNothing);
  });

  testWidgets('turning it on prompts once and stores the flag', (tester) async {
    final biometric = FakeBiometricBackend();
    final overrides = await securityOverrides(tester, biometric: biometric);
    await pumpSecurityPage(tester, overrides: overrides);

    await tester.tap(_switch);
    await tester.pumpAndSettle();

    expect(biometric.reasons, hasLength(1));
    expect(tester.widget<Switch>(_switch).value, isTrue);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SecuritySettingsPage)),
    );
    expect(container.read(appLockControllerProvider).enabled, isTrue);
  });

  testWidgets('a cancelled prompt keeps it off and says so', (tester) async {
    final biometric = FakeBiometricBackend(result: BiometricResult.cancelled);
    await pumpSecurityPage(
      tester,
      overrides: await securityOverrides(tester, biometric: biometric),
    );

    await tester.tap(_switch);
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(_switch).value, isFalse);
    expect(find.textContaining('cancelled'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed prompt keeps it off and says so', (tester) async {
    final biometric = FakeBiometricBackend(result: BiometricResult.failed);
    await pumpSecurityPage(
      tester,
      overrides: await securityOverrides(tester, biometric: biometric),
    );

    await tester.tap(_switch);
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(_switch).value, isFalse);
    expect(find.textContaining('failed'), findsOneWidget);
  });

  testWidgets('turning it off needs no prompt', (tester) async {
    final biometric = FakeBiometricBackend();
    await pumpSecurityPage(
      tester,
      overrides: await securityOverrides(
        tester,
        biometric: biometric,
        prefs: {
          appLockPrefKey: ['1'],
        },
      ),
    );
    expect(tester.widget<Switch>(_switch).value, isTrue);

    await tester.tap(_switch);
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(_switch).value, isFalse);
    expect(biometric.reasons, isEmpty);
  });

  testWidgets('without biometrics the switch is disabled and explained', (
    tester,
  ) async {
    await pumpSecurityPage(
      tester,
      overrides: await securityOverrides(
        tester,
        biometric: FakeBiometricBackend(available: false),
      ),
    );

    expect(tester.widget<Switch>(_switch).onChanged, isNull);
    expect(find.byKey(const ValueKey('security-unavailable')), findsOneWidget);
    expect(find.textContaining('device passcode'), findsWidgets);
  });

  testWidgets('loading shows a skeleton', (tester) async {
    final overrides = await securityOverrides(tester);
    await pumpApp(
      tester,
      const SecuritySettingsPage(),
      overrides: [
        ...overrides,
        biometricAvailableProvider.overrideWith(
          (ref) => Completer<bool>().future,
        ),
      ],
    );
    await tester.pump();

    expect(find.byType(SkeletonList), findsOneWidget);
    expect(_switch, findsNothing);
  });

  testWidgets('a failed device check shows the error state with retry', (
    tester,
  ) async {
    final overrides = await securityOverrides(tester);
    await pumpApp(
      tester,
      const SecuritySettingsPage(),
      overrides: [
        ...overrides,
        biometricAvailableProvider.overrideWith(
          (ref) => Future<bool>.error(StateError('boom')),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.byType(ErrorState), findsOneWidget);
    expect(_switch, findsNothing);
  });

  testWidgets('arabic shows translated texts', (tester) async {
    await pumpSecurityPage(
      tester,
      overrides: await securityOverrides(tester),
      locale: const Locale('ar'),
    );

    expect(find.text('الأمان'), findsOneWidget);
    expect(find.text('قفل التطبيق'), findsOneWidget);
    expect(find.text('App lock'), findsNothing);
  });

  testWidgets('survives text scale 2.0 in ar and en on phone and tablet', (
    tester,
  ) async {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      for (final size in const [Size(400, 800), Size(900, 1200)]) {
        await pumpSecurityPage(
          tester,
          overrides: await securityOverrides(
            tester,
            biometric: FakeBiometricBackend(available: false),
          ),
          locale: locale,
          textScale: 2,
          size: size,
        );
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('the switch row keeps a 48 dp touch target', (tester) async {
    await pumpSecurityPage(tester, overrides: await securityOverrides(tester));
    expect(
      tester.getSize(find.byType(SwitchListTile)).height,
      greaterThanOrEqualTo(48),
    );
  });
}

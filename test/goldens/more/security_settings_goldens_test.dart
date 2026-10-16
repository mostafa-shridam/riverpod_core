import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/security/app_lock_screen.dart';
import 'package:riverpod_core/core/security/app_lock_controller.dart';
import 'package:riverpod_core/features/more/presentation/pages/security_settings_page.dart';

import '../../core/security/security_fakes.dart';
import '../../helpers/helpers.dart';

void main() {
  const modes = <(ThemeMode, String)>[
    (ThemeMode.light, 'en'),
    (ThemeMode.dark, 'en'),
    (ThemeMode.light, 'ar'),
    (ThemeMode.dark, 'ar'),
  ];

  for (final (mode, lang) in modes) {
    testWidgets('security settings on ${mode.name} $lang', (tester) async {
      await pumpApp(
        tester,
        const SecuritySettingsPage(),
        overrides: await securityOverrides(
          tester,
          prefs: {
            appLockPrefKey: ['1'],
          },
        ),
        themeMode: mode,
        locale: Locale(lang),
        size: const Size(390, 760),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(SecuritySettingsPage),
        matchesGoldenFile('security_settings_${mode.name}_$lang.png'),
      );
    });

    testWidgets('lock screen ${mode.name} $lang', (tester) async {
      await pumpApp(
        tester,
        AppLockScreen(onUnlock: () {}),
        themeMode: mode,
        locale: Locale(lang),
        size: const Size(390, 760),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(AppLockScreen),
        matchesGoldenFile('lock_screen_${mode.name}_$lang.png'),
      );
    });
  }

  for (final lang in ['en', 'ar']) {
    testWidgets('security settings unavailable on tablet $lang', (
      tester,
    ) async {
      await pumpApp(
        tester,
        const SecuritySettingsPage(),
        overrides: await securityOverrides(
          tester,
          biometric: FakeBiometricBackend(available: false),
        ),
        locale: Locale(lang),
        size: const Size(900, 1000),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(SecuritySettingsPage),
        matchesGoldenFile('security_settings_tablet_unavailable_$lang.png'),
      );
    });
  }
}

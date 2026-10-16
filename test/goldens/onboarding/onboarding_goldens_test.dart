import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/features/onboarding/presentation/pages/onboarding_page.dart';

import '../../features/auth/auth_harness.dart';
import '../../helpers/helpers.dart';

void main() {
  final cases = <(ThemeMode, String)>[
    (ThemeMode.light, 'en'),
    (ThemeMode.dark, 'en'),
    (ThemeMode.light, 'ar'),
    (ThemeMode.dark, 'ar'),
  ];

  for (final (mode, lang) in cases) {
    testWidgets('onboarding ${mode.name} $lang', (tester) async {
      final prefs = await tester.runAsync(() => fakePrefsStorage());
      await pumpAuthPage(
        tester,
        const OnboardingPage(),
        themeMode: mode,
        locale: Locale(lang),
        size: const Size(390, 760),
        overrides: [
          prefsStorageProvider.overrideWith((ref) => Future.value(prefs)),
        ],
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('onboarding_${mode.name}_$lang.png'),
      );
    });
  }
}

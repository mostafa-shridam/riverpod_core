import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';
import 'package:riverpod_core/features/auth/presentation/pages/login_page.dart';
import 'package:riverpod_core/features/auth/presentation/pages/register_page.dart';

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
    testWidgets('login ${mode.name} $lang', (tester) async {
      await pumpAuthPage(
        tester,
        const LoginPage(),
        themeMode: mode,
        locale: Locale(lang),
        size: const Size(390, 760),
        overrides: [
          secureStorageProvider.overrideWithValue(FakeSecureStorage()),
        ],
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('login_${mode.name}_$lang.png'),
      );
    });

    testWidgets('register ${mode.name} $lang', (tester) async {
      await pumpAuthPage(
        tester,
        const RegisterPage(),
        themeMode: mode,
        locale: Locale(lang),
        size: const Size(390, 760),
        overrides: [
          secureStorageProvider.overrideWithValue(FakeSecureStorage()),
        ],
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('register_${mode.name}_$lang.png'),
      );
    });
  }
}

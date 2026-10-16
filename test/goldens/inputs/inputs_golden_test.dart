import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/inputs/app_otp_field.dart';
import 'package:riverpod_core/core/design_system/widgets/inputs/app_password_field.dart';
import 'package:riverpod_core/core/design_system/widgets/inputs/app_search_field.dart';
import 'package:riverpod_core/core/design_system/widgets/inputs/app_text_field.dart';

import '../../helpers/helpers.dart';

Widget _gallery() {
  return const Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(label: 'Full name', helper: 'As on your ID'),
        SizedBox(height: 16),
        AppTextField(label: 'Email', errorText: 'Enter a valid email address'),
        SizedBox(height: 16),
        AppPasswordField(label: 'Password'),
        SizedBox(height: 16),
        AppSearchField(),
        SizedBox(height: 16),
        AppOtpField(length: 6),
      ],
    ),
  );
}

void main() {
  final cases = <(ThemeMode, String)>[
    (ThemeMode.light, 'en'),
    (ThemeMode.dark, 'en'),
    (ThemeMode.light, 'ar'),
    (ThemeMode.dark, 'ar'),
  ];

  for (final (mode, lang) in cases) {
    testWidgets('inputs $mode $lang', (tester) async {
      await pumpApp(
        tester,
        themeMode: mode,
        locale: Locale(lang),
        size: const Size(360, 720),
        _gallery(),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('inputs_${mode.name}_$lang.png'),
      );
    });
  }
}

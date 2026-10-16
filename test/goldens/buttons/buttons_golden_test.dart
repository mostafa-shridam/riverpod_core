import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_icon_button.dart';

import '../../helpers/helpers.dart';

Widget _gallery() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final variant in AppButtonVariant.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppButton(
              label: variant.name,
              variant: variant,
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        const AppButton(label: 'Loading', onPressed: null, isLoading: true),
        Row(
          children: [
            for (final variant in AppIconButtonVariant.values)
              AppIconButton(
                icon: Icons.favorite,
                tooltip: variant.name,
                variant: variant,
                onPressed: () {},
              ),
          ],
        ),
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
    testWidgets('buttons $mode $lang', (tester) async {
      await pumpApp(
        tester,
        themeMode: mode,
        locale: Locale(lang),
        size: const Size(360, 640),
        _gallery(),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('buttons_${mode.name}_$lang.png'),
      );
    });
  }
}

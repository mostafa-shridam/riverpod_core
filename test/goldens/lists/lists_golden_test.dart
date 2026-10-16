import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/lists/pagination_footer.dart';

import '../../helpers/helpers.dart';

Widget _footers() {
  return const SizedBox(
    width: 360,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PaginationFooter(status: PaginationFooterStatus.loading),
        PaginationFooter(status: PaginationFooterStatus.end),
        PaginationFooter(
          status: PaginationFooterStatus.error,
          errorText: 'Something went wrong. Please try again.',
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
    testWidgets('lists footers $mode $lang', (tester) async {
      await pumpApp(
        tester,
        themeMode: mode,
        locale: Locale(lang),
        size: const Size(360, 640),
        _footers(),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('lists_footers_${mode.name}_$lang.png'),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/design_system/widgets/display/ds_test_harness.dart';
import 'showcase_test_support.dart';

void main() {
  for (final mode in goldenModes) {
    testWidgets('top of the page ${mode.name}', (tester) async {
      await pumpShowcase(
        tester,
        locale: mode.locale,
        dark: mode.dark,
        size: const Size(400, 800),
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../goldens/showcase/top_${mode.name}.png'),
      );
    });
  }
}

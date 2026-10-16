import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/features/showcase/presentation/pages/showcase_page.dart';

import '../../core/design_system/widgets/display/ds_test_harness.dart';
import '../../core/design_system/widgets/media/fake_video_backend.dart';

/// Section keys in page order.
const showcaseSectionKeys = [
  'showcase-buttons',
  'showcase-inputs',
  'showcase-selection',
  'showcase-overlays',
  'showcase-display',
  'showcase-media',
  'showcase-states',
  'showcase-tokens',
];

/// Pumps the gallery with a fake video engine and the real translations.
/// Network images fail fast in tests, which shows the error state.
Future<void> pumpShowcase(
  WidgetTester tester, {
  String locale = 'en',
  bool dark = false,
  double textScale = 1.0,
  Size size = phoneSize,
}) {
  return pumpDs(
    tester,
    ProviderScope(
      child: ShowcasePage(
        videoBackendFactory: (source) => FakeVideoBackend(source),
      ),
    ),
    locale: locale,
    dark: dark,
    textScale: textScale,
    size: size,
    scaffold: false,
  );
}

/// Scrolls the gallery list until [finder] is built and on screen.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find
        .descendant(
          of: find.byKey(const ValueKey('showcase-list')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

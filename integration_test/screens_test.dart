import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

import 'helpers/flow_setup.dart';
import 'helpers/pump_until.dart';

/// The screens the owner looks at. Screenshots are written only when run
/// under `flutter drive` with `--dart-define=CAPTURE_SCREENS=true`; under
/// `flutter test` this test only walks the screens.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shot(String name) async {
    if (captureScreens) await binding.takeScreenshot(name);
  }

  testWidgets('screens for the owner', (tester) async {
    if (captureScreens) await binding.convertFlutterSurfaceToImage();
    await startApp(tester);
    await tester.pump(const Duration(milliseconds: 200));
    await shot('splash');

    await pumpUntilFound(tester, find.text(LocaleKeys.onboarding_next.tr()));
    await shot('onboarding');
    await tester.tap(find.text(LocaleKeys.onboarding_next.tr()));
    await tester.pump();
    await tester.tap(find.text(LocaleKeys.onboarding_next.tr()));
    await tester.pump();
    await tapWhenFound(
      tester,
      find.text(LocaleKeys.onboarding_getStarted.tr()),
    );

    await pumpUntilFound(tester, find.byKey(const ValueKey('login-page')));
    await shot('login');

    await tester.enterText(find.byType(TextField).at(0), 'reader@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'a-long-password');
    await tapWhenFound(
      tester,
      find.widgetWithText(AppButton, LocaleKeys.auth_login_submit.tr()),
    );
    await pumpUntilFound(tester, find.byKey(const ValueKey('home-page')));
    await shot('home');

    await tapWhenFound(tester, find.byKey(const ValueKey('home-videos-tile')));
    await pumpUntilFound(tester, find.text(LocaleKeys.videos_title.tr()));
    await shot('videos-list');

    // Back to home, then the showcase: English light, dark, then Arabic in
    // dark and light (the page toggles theme and locale).
    await tester.pageBack();
    await tester.pump();
    await pumpUntilFound(tester, find.byKey(const ValueKey('home-page')));
    await tapWhenFound(tester, find.byKey(const ValueKey('open-showcase')));
    await pumpUntilFound(tester, find.byKey(const ValueKey('showcase-list')));
    await shot('showcase-en-light');
    await tapWhenFound(tester, find.byKey(const ValueKey('toggle-theme')));
    await shot('showcase-en-dark');
    await tapWhenFound(tester, find.byKey(const ValueKey('toggle-locale')));
    await shot('showcase-ar-dark');
    await tapWhenFound(tester, find.byKey(const ValueKey('toggle-theme')));
    await shot('showcase-ar-light');
  });
}

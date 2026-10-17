import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/router/routes.dart';
import 'package:riverpod_core/features/videos/data/sources/sample_videos.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

import 'helpers/flow_setup.dart';
import 'helpers/pump_until.dart';
import 'helpers/screen_capture.dart';

/// The screens the owner looks at. Screenshots are written only when run
/// under `flutter drive` with `--dart-define=CAPTURE_SCREENS=true`; under
/// `flutter test` this test only walks the screens.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('screens for the owner', (tester) async {
    // Captured from the Flutter layer: takeScreenshot returns the native launch
    // screen on iOS.
    final capture = ScreenCapture(binding, tester);
    Future<void> shot(String name) async {
      if (captureScreens) await capture.shot(name);
    }

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

    // The first video's detail page (the fake player keeps the surface fixed).
    await tapWhenFound(tester, find.text(sampleVideos.first.title));
    await pumpUntilFound(tester, find.byKey(const ValueKey('flow-video')));
    await shot('video-detail');
    await popRoute(tester);
    await popRoute(tester);
    await pumpUntilFound(tester, find.byKey(const ValueKey('home-page')));

    // More is reached by route, not by its tab: a tap on the tab is the known
    // defect in ai-docs/reports/C-26.md.
    final home = tester.element(find.byKey(const ValueKey('home-page')));
    const MoreRoute().go(home);
    await pumpUntilFound(tester, find.byKey(const ValueKey('more-page')));
    await shot('more');
    const HomeRoute().go(
      tester.element(find.byKey(const ValueKey('more-page'))),
    );
    await pumpUntilFound(tester, find.byKey(const ValueKey('home-page')));

    // The showcase: English light, dark, then Arabic in dark and light (the
    // page toggles theme and locale).
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

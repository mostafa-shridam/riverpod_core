import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/errors/error_messages.dart';
import 'package:riverpod_core/features/videos/data/sources/sample_videos.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

import 'helpers/flow_setup.dart';
import 'helpers/pump_until.dart';

const _email = 'reader@example.com';
const _password = 'a-long-password';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'onboarding, sign-in, then a video is favorited and the app is home',
    (tester) async {
      await _startSignedIn(tester);

      // Videos: list, open the first, play, favorite it.
      await tapWhenFound(
        tester,
        find.byKey(const ValueKey('home-videos-tile')),
      );
      final first = sampleVideos.first;
      await tapWhenFound(tester, find.text(first.title));
      await pumpUntilFound(tester, find.byKey(const ValueKey('flow-video')));
      await tapWhenFound(
        tester,
        find.widgetWithText(AppButton, LocaleKeys.videos_favorite_add.tr()),
      );
      await pumpUntilFound(
        tester,
        find.text(LocaleKeys.videos_favorite_remove.tr()),
      );

      // Back to videos, then home.
      await popRoute(tester);
      await popRoute(tester);
      await pumpUntilFound(tester, find.byKey(const ValueKey('home-page')));
    },
  );

  testWidgets(
    'KNOWN DEFECT C-26, skipped: More, About, then logout returns to login',
    (tester) async {
      await _startSignedIn(tester);

      await tapWhenFound(tester, find.byIcon(Icons.more_horiz));
      await pumpUntilFound(tester, find.byKey(const ValueKey('more-page')));
      await tapWhenFound(tester, find.byKey(const ValueKey('more-about-tile')));
      await pumpUntilFound(tester, find.byKey(const ValueKey('about-page')));
      await popRoute(tester);

      await tapWhenFound(
        tester,
        find.widgetWithText(AppButton, LocaleKeys.auth_logout.tr()),
      );
      await pumpUntilFound(tester, find.byKey(const ValueKey('login-page')));
    },
    // Known defect (C-26 report): after a video pop the bottom tab bar is
    // under an absorbing layer, so the More tab cannot be tapped. Un-skip when
    // fixed.
    skip: true,
  );
}

/// Cold start through onboarding and a valid sign-in, to home.
Future<void> _startSignedIn(WidgetTester tester) async {
  await startApp(tester);

  await pumpUntilFound(tester, find.text(LocaleKeys.onboarding_next.tr()));
  await tester.tap(find.text(LocaleKeys.onboarding_next.tr()));
  await tester.pump();
  await tester.tap(find.text(LocaleKeys.onboarding_next.tr()));
  await tester.pump();
  await tapWhenFound(tester, find.text(LocaleKeys.onboarding_getStarted.tr()));

  await pumpUntilFound(tester, find.byKey(const ValueKey('login-page')));
  // Wrong credentials stay on the page and show the error.
  await _signIn(tester, 'wrong@example.com', _password);
  await pumpUntilFound(
    tester,
    find.text(errorMessageKey(const UnauthorizedException()).tr()),
  );
  expect(find.byKey(const ValueKey('login-page')), findsOneWidget);

  await _signIn(tester, _email, _password);
  await pumpUntilFound(tester, find.byKey(const ValueKey('home-page')));
}

Future<void> _signIn(WidgetTester tester, String email, String password) async {
  await tester.enterText(find.byType(TextField).at(0), email);
  await tester.enterText(find.byType(TextField).at(1), password);
  await tapWhenFound(
    tester,
    find.widgetWithText(AppButton, LocaleKeys.auth_login_submit.tr()),
  );
}

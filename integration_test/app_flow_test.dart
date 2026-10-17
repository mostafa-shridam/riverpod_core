import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/errors/error_messages.dart';
import 'package:riverpod_core/core/router/routes.dart';
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
      await _favoriteFirstVideoAndLeave(tester);
    },
  );

  testWidgets(
    'KNOWN OPEN ITEM, skipped: More, About, then logout returns to login',
    (tester) async {
      await _startSignedIn(tester);
      await _favoriteFirstVideoAndLeave(tester);

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
    skip: true,
  );

  testWidgets(
    'KNOWN OPEN ITEM, skipped: More opens after an items detail is popped',
    (tester) async {
      await _startSignedIn(tester);
      final home = tester.element(find.byKey(const ValueKey('home-page')));
      unawaited(const ItemDetailRoute(id: '42').push<void>(home));
      await pumpUntilFound(
        tester,
        find.byKey(const ValueKey('item-detail-page')),
      );
      await popRoute(tester);

      await tapWhenFound(tester, find.byIcon(Icons.more_horiz));
      await pumpUntilFound(tester, find.byKey(const ValueKey('more-page')));
    },
    skip: true,
  );
}

/// Opens the first video, favorites it (the toast stays up), and pops back to
/// home. The pops happen while the toast is still on screen.
Future<void> _favoriteFirstVideoAndLeave(WidgetTester tester) async {
  await tapWhenFound(tester, find.byKey(const ValueKey('home-videos-tile')));
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
  await popRoute(tester);
  await popRoute(tester);
  await pumpUntilFound(tester, find.byKey(const ValueKey('home-page')));
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

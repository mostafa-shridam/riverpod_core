import 'dart:convert';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/auth/auth_tokens.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/constants.dart';
import 'package:riverpod_core/core/design_system/theme/app_theme.dart';
import 'package:riverpod_core/core/helper/deep_link_helper.dart';
import 'package:riverpod_core/core/network/session_events.dart';
import 'package:riverpod_core/core/router/app_router.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';
import 'package:riverpod_core/generated/codegen_loader.g.dart';
import 'package:riverpod_core/shared/models/auth_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/helpers.dart';

Future<ProviderContainer> _container(
  WidgetTester tester, {
  required bool onboardingSeen,
}) async {
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();
  final prefs = await tester.runAsync(
    () => fakePrefsStorage({if (onboardingSeen) PrefKeys.onboardingSeen: true}),
  );
  return createContainer(
    overrides: [
      prefsStorageProvider.overrideWith((ref) => Future.value(prefs)),
      secureStorageProvider.overrideWithValue(FakeSecureStorage()),
    ],
  );
}

Future<void> _pumpRouter(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: EasyLocalization(
        supportedLocales: supportedLocales,
        path: translationsPath,
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        assetLoader: const CodegenLoader(),
        saveLocale: false,
        child: Builder(
          builder: (context) => Consumer(
            builder: (context, ref, _) => MaterialApp.router(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              theme: buildLightTheme(),
              routerConfig: ref.watch(appRouterProvider),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _signIn(ProviderContainer container) {
  return container
      .read(sessionControllerProvider.notifier)
      .signIn(
        tokens: const AuthTokens(accessToken: 'a', refreshToken: 'r'),
        user: const AuthUser(id: '1', email: 'a@b.co', name: 'A'),
      );
}

Finder _page(String key) => find.byKey(ValueKey(key));

void main() {
  group('startup and guards', () {
    testWidgets('a new user sees onboarding first', (tester) async {
      final container = await _container(tester, onboardingSeen: false);
      addTearDown(container.dispose);
      await container.read(sessionControllerProvider.notifier).restore();

      await _pumpRouter(tester, container);

      expect(_page('onboarding-page'), findsOneWidget);
    });

    testWidgets('signed out after onboarding shows login', (tester) async {
      final container = await _container(tester, onboardingSeen: true);
      addTearDown(container.dispose);
      await container.read(sessionControllerProvider.notifier).restore();

      await _pumpRouter(tester, container);

      expect(_page('login-page'), findsOneWidget);
    });

    testWidgets('signed in shows home', (tester) async {
      final container = await _container(tester, onboardingSeen: true);
      addTearDown(container.dispose);
      await _signIn(container);

      await _pumpRouter(tester, container);

      expect(_page('home-page'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('an expired session sends the user back to login', (
      tester,
    ) async {
      final container = await _container(tester, onboardingSeen: true);
      addTearDown(container.dispose);
      await _signIn(container);
      await _pumpRouter(tester, container);
      expect(_page('home-page'), findsOneWidget);

      container.read(sessionEventsProvider).notifyExpired();
      await tester.pumpAndSettle();

      expect(_page('login-page'), findsOneWidget);
    });
  });

  group('navigation', () {
    testWidgets('an unknown location shows the error page', (tester) async {
      final container = await _container(tester, onboardingSeen: true);
      addTearDown(container.dispose);
      await _signIn(container);
      await _pumpRouter(tester, container);

      container.read(appRouterProvider).go('/does-not-exist');
      await tester.pumpAndSettle();

      expect(_page('error-page'), findsOneWidget);
    });

    testWidgets('a deep link opens the typed item route', (tester) async {
      final container = await _container(tester, onboardingSeen: true);
      addTearDown(container.dispose);
      await _signIn(container);
      await _pumpRouter(tester, container);

      await tester.runAsync(
        () => DeepLinkHelper.instance.handleRouteById(
          pyload: jsonEncode({'id': '42', 'page': 'myEvents'}),
        ),
      );
      await tester.pumpAndSettle();

      expect(_page('item-detail-page'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });
  });
}

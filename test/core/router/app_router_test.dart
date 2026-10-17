import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/analytics/analytics_service.dart';
import 'package:riverpod_core/core/app_info/app_info.dart';
import 'package:riverpod_core/core/auth/auth_tokens.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/design_system/theme/app_theme.dart';
import 'package:riverpod_core/core/localization/app_locales.dart';
import 'package:riverpod_core/core/network/session_events.dart';
import 'package:riverpod_core/core/notifications/models/notification_payload.dart';
import 'package:riverpod_core/core/notifications/models/notification_tap.dart';
import 'package:riverpod_core/core/notifications/models/notification_tap_source.dart';
import 'package:riverpod_core/core/notifications/routing/notification_router_provider.dart';
import 'package:riverpod_core/core/remote_config/remote_config_provider.dart';
import 'package:riverpod_core/core/remote_config/remote_config_source.dart';
import 'package:riverpod_core/core/router/app_router.dart';
import 'package:riverpod_core/core/startup/startup_controller.dart';
import 'package:riverpod_core/core/storage/cache/cache_store.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';
import 'package:riverpod_core/generated/codegen_loader.g.dart';
import 'package:riverpod_core/shared/models/auth_user.dart';

import '../../helpers/fake_analytics.dart';
import '../../helpers/helpers.dart';

/// The installed app facts without the platform channel.
class _FixedAppInfo implements AppInfoSource {
  const _FixedAppInfo();

  @override
  Future<AppInfo> load() async => const AppInfo(
    name: 'Test App',
    version: '1.0.0',
    buildNumber: '1',
    packageName: 'test.app',
  );
}

Future<ProviderContainer> _container(
  WidgetTester tester, {
  required bool onboardingSeen,
  List<Override> overrides = const [],
}) async {
  await EasyLocalization.ensureInitialized();
  final storage = await tester.runAsync(() async {
    final opened = await openTestStorage();
    await opened.settings.putAll({
      if (onboardingSeen) PrefKeys.onboardingSeen: true,
    });
    return opened;
  });
  final opened = storage!;
  final prefs = PrefsStorage(opened.settings);
  final container = createContainer(
    overrides: [
      // The home page reads the flavor for the dev-only gallery entry.
      appConfigProvider.overrideWithValue(
        AppConfig.fromMap(Flavor.dev, const {
          'APP_NAME': 'Test App',
          'API_BASE_URL': 'https://api.example.com',
          'CONNECT_TIMEOUT_MS': '15000',
          'RECEIVE_TIMEOUT_MS': '20000',
        }),
      ),
      prefsStorageProvider.overrideWith((ref) => Future.value(prefs)),
      secureStorageProvider.overrideWithValue(FakeSecureStorage()),
      splashMinimumDisplayProvider.overrideWithValue(Duration.zero),
      cacheStoreProvider.overrideWithValue(CacheStore(opened.cache)),
      appInfoSourceProvider.overrideWithValue(const _FixedAppInfo()),
      remoteConfigSourceProvider.overrideWithValue(
        const MockRemoteConfigSource(),
      ),
      ...overrides,
    ],
  );
  // The router waits for the startup sequence (restore, settings read).
  await tester.runAsync(() => container.read(startupControllerProvider.future));
  return container;
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

      await _pumpRouter(tester, container);

      expect(_page('onboarding-page'), findsOneWidget);
    });

    testWidgets('signed out after onboarding shows login', (tester) async {
      final container = await _container(tester, onboardingSeen: true);
      addTearDown(container.dispose);

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
      // The expiry handler deletes the stored user asynchronously; let it
      // finish before the router is pumped.
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();

      expect(_page('login-page'), findsOneWidget);
    });
  });

  group('navigation', () {
    testWidgets('navigating logs screen views', (tester) async {
      final analytics = FakeAnalytics();
      final container = await _container(
        tester,
        onboardingSeen: true,
        overrides: [analyticsServiceProvider.overrideWithValue(analytics)],
      );
      addTearDown(container.dispose);
      await _signIn(container);
      await _pumpRouter(tester, container);
      expect(analytics.screens, isNotEmpty);
      final before = analytics.screens.length;

      container
          .read(notificationRouterProvider)
          .handle(
            const NotificationTap(
              payload: NotificationPayload(type: 'myEvents', id: '42'),
              source: NotificationTapSource.localTap,
            ),
          );
      await tester.pumpAndSettle();

      expect(analytics.screens.length, greaterThan(before));
      expect(analytics.screens.last, isNot(analytics.screens[before - 1]));
    });

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

      container
          .read(notificationRouterProvider)
          .handle(
            const NotificationTap(
              payload: NotificationPayload(type: 'myEvents', id: '42'),
              source: NotificationTapSource.localTap,
            ),
          );
      await tester.pumpAndSettle();

      expect(_page('item-detail-page'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('a custom-scheme link opens the typed route (C-31)', (
      tester,
    ) async {
      final container = await _container(tester, onboardingSeen: true);
      addTearDown(container.dispose);
      await _signIn(container);
      await _pumpRouter(tester, container);

      container.read(appRouterProvider).go('riverpod-core://items/42');
      await tester.pumpAndSettle();

      expect(_page('item-detail-page'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('a link opened while signed out is replayed after sign-in', (
      tester,
    ) async {
      final container = await _container(tester, onboardingSeen: true);
      addTearDown(container.dispose);
      await _pumpRouter(tester, container);
      expect(_page('login-page'), findsOneWidget);

      container.read(appRouterProvider).go('https://example.com/items/42');
      await tester.pumpAndSettle();
      expect(_page('login-page'), findsOneWidget);
      expect(_page('item-detail-page'), findsNothing);

      await _signIn(container);
      await tester.pumpAndSettle();

      expect(_page('item-detail-page'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });
  });
}

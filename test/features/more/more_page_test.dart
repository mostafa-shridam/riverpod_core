import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_core/core/app_info/app_info.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/config/log_level.dart';
import 'package:riverpod_core/core/constants.dart';
import 'package:riverpod_core/core/design_system/theme/app_theme.dart';
import 'package:riverpod_core/features/more/presentation/pages/about_page.dart';
import 'package:riverpod_core/features/more/presentation/pages/more_page.dart';
import 'package:riverpod_core/generated/codegen_loader.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_native_backends.dart';

void main() {
  testWidgets('the About tile opens the About page', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(EasyLocalization.ensureInitialized);
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: MorePage.routeName,
      routes: [
        GoRoute(
          path: MorePage.routeName,
          builder: (context, state) => const MorePage(),
        ),
        GoRoute(
          path: AboutPage.routeName,
          builder: (context, state) => const AboutPage(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(
              flavor: Flavor.dev,
              appName: 'Demo',
              apiBaseUrl: 'https://api.example.test',
              connectTimeout: Duration(seconds: 15),
              receiveTimeout: Duration(seconds: 30),
              logLevel: LogLevel.off,
              enableCrashReporting: false,
              enableAnalytics: false,
            ),
          ),
          appInfoSourceProvider.overrideWithValue(
            FakeAppInfoSource(
              const AppInfo(
                name: 'Demo',
                version: '1.0.0',
                buildNumber: '1',
                packageName: 'p',
              ),
            ),
          ),
        ],
        child: EasyLocalization(
          supportedLocales: supportedLocales,
          path: translationsPath,
          fallbackLocale: const Locale('en'),
          startLocale: const Locale('en'),
          assetLoader: const CodegenLoader(),
          saveLocale: false,
          child: Builder(
            builder: (context) => MaterialApp.router(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              theme: buildLightTheme(),
              routerConfig: router,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('more-page')), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('more-about-tile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('about-page')), findsOneWidget);
    expect(find.text('1.0.0'), findsOneWidget);
  });
}

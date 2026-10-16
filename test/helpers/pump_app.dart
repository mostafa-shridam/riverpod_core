import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/constants.dart';
import 'package:riverpod_core/core/design_system/responsive/text_scale.dart';
import 'package:riverpod_core/core/design_system/theme/app_theme.dart';
import 'package:riverpod_core/generated/codegen_loader.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Default phone window used when a test does not pass [size].
const Size defaultTestSize = Size(400, 800);

/// Pumps [child] inside the same wrapper the app uses: `ProviderScope`,
/// `EasyLocalization` (in-memory translations), and `MaterialApp` with the
/// design_system themes. The system text scale goes through
/// [clampTextScale], exactly as in `main.dart`.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  double textScale = 1.0,
  Size size = defaultTestSize,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size;
  addTearDown(tester.view.reset);

  // No platform channels in tests: mock prefs and do real async work outside
  // the fake clock of testWidgets.
  SharedPreferences.setMockInitialValues({});
  await tester.runAsync(EasyLocalization.ensureInitialized);

  // EasyLocalization reads startLocale only in initState: unmount first so
  // each call starts from a fresh localization state.
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: EasyLocalization(
        supportedLocales: supportedLocales,
        path: translationsPath,
        fallbackLocale: const Locale('en'),
        startLocale: locale,
        assetLoader: const CodegenLoader(),
        saveLocale: false,
        ignorePluralRules: false,
        child: Builder(
          builder: (context) => MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: themeMode,
            builder: (context, app) {
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(
                  textScaler: clampTextScale(TextScaler.linear(textScale)),
                ),
                child: app!,
              );
            },
            home: Scaffold(body: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

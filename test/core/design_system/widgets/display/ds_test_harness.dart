import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads the real translation files from disk, so widget tests resolve the
/// same ar/en strings as the app without the asset bundle. Reads
/// synchronously: real async file I/O never completes inside `testWidgets`.
class _FileAssetLoader extends AssetLoader {
  const _FileAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    final file = File('assets/translations/${locale.languageCode}.json');
    return json.decode(file.readAsStringSync()) as Map<String, dynamic>;
  }
}

/// Phone and tablet window sizes used by the display/layout tests.
const phoneSize = Size(400, 800);
const tabletSize = Size(800, 900);
const desktopSize = Size(1100, 800);

/// Pumps [child] inside a themed, localized `MaterialApp`.
///
/// [scaffold] wraps [child] in a `Scaffold` (Material ancestor); turn it off
/// when [child] is a page frame itself.
///
/// Animations are disabled by default so repeating animations (shimmer) do
/// not block `pumpAndSettle`; pass `disableAnimations: false` to test motion.
Future<void> pumpDs(
  WidgetTester tester,
  Widget child, {
  String locale = 'en',
  bool dark = false,
  double textScale = 1.0,
  Size size = phoneSize,
  bool disableAnimations = true,
  bool scaffold = true,
}) async {
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableBuildModes = [];
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    EasyLocalization(
      // New state per pump, so a second pump can switch the locale.
      key: UniqueKey(),
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      assetLoader: const _FileAssetLoader(),
      startLocale: Locale(locale),
      saveLocale: false,
      useOnlyLangCode: true,
      child: Builder(
        builder: (context) => MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          builder: (context, app) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
              disableAnimations: disableAnimations,
            ),
            child: app!,
          ),
          home: scaffold ? Scaffold(body: child) : child,
        ),
      ),
    ),
  );
  if (disableAnimations) {
    await tester.pumpAndSettle();
  } else {
    // Repeating animations (shimmer) never settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
  }
}

/// Golden matrix: light/dark x en/ar at text scale 2.0 is exercised by the
/// callers through this list.
const goldenModes = <({String name, String locale, bool dark})>[
  (name: 'light_en', locale: 'en', dark: false),
  (name: 'dark_en', locale: 'en', dark: true),
  (name: 'light_ar', locale: 'ar', dark: false),
  (name: 'dark_ar', locale: 'ar', dark: true),
];

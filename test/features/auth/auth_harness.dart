import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/theme/app_theme.dart';

/// Translations read straight from `assets/translations`, so widget tests show
/// the real strings without the generated loader.
class JsonTranslationsLoader extends AssetLoader {
  JsonTranslationsLoader()
    : _maps = {
        for (final locale in ['en', 'ar'])
          locale:
              jsonDecode(
                    File('assets/translations/$locale.json').readAsStringSync(),
                  )
                  as Map<String, dynamic>,
      };

  final Map<String, Map<String, dynamic>> _maps;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    return _maps[locale.languageCode];
  }
}

/// Pumps [page] with the app's theme, localization and the given overrides.
Future<void> pumpAuthPage(
  WidgetTester tester,
  Widget page, {
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  Size size = const Size(400, 800),
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: locale,
        assetLoader: JsonTranslationsLoader(),
        saveLocale: false,
        child: Builder(
          builder: (context) => MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: themeMode,
            home: page,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

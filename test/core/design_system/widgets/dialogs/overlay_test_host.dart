import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads `assets/translations/<lang>.json` synchronously so it works inside
/// the fake-async zone of `testWidgets`.
class _FileAssetLoader extends AssetLoader {
  const _FileAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    final text = File(
      'assets/translations/${locale.languageCode}.json',
    ).readAsStringSync();
    return Future.value(json.decode(text) as Map<String, dynamic>);
  }
}

/// Call once in `setUpAll` of every test file that uses [pumpOverlayHost].
Future<void> setUpOverlayTests() async {
  SharedPreferences.setMockInitialValues({});
  TestWidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableLevels = [];
}

const phoneSize = Size(390, 844);
const tabletSize = Size(900, 1000);

/// Pumps [home] in a themed, localized app inside a `ProviderScope`.
Future<void> pumpOverlayHost(
  WidgetTester tester,
  Widget home, {
  Locale locale = const Locale('en'),
  bool dark = false,
  double textScale = 1.0,
  Size size = phoneSize,
  GlobalKey<ScaffoldMessengerState>? messengerKey,
  bool endless = false,
  ProviderContainer? container,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  Widget scope({required Widget child}) => container == null
      ? ProviderScope(child: child)
      : UncontrolledProviderScope(container: container, child: child);
  await tester.pumpWidget(
    scope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        startLocale: locale,
        saveLocale: false,
        assetLoader: const _FileAssetLoader(),
        child: Builder(
          builder: (context) => MaterialApp(
            scaffoldMessengerKey: messengerKey,
            debugShowCheckedModeBanner: false,
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: dark ? ThemeMode.dark : ThemeMode.light,
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
            home: home,
          ),
        ),
      ),
    ),
  );
  await settle(tester, endless: endless);
}

/// Waits for animations. [endless] is for trees with a spinner, where
/// `pumpAndSettle` would time out: it advances a fixed span instead.
Future<void> settle(WidgetTester tester, {bool endless = false}) async {
  if (endless) {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  } else {
    await tester.pumpAndSettle();
  }
}

/// A scaffold with one button; tapping it runs [onOpen] with a context below
/// the navigator.
class OpenerPage extends StatelessWidget {
  const OpenerPage({required this.onOpen, super.key});

  final void Function(BuildContext context) onOpen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => onOpen(context),
          child: const Text('open'),
        ),
      ),
    );
  }
}

/// Taps the opener button and waits for the overlay to settle.
Future<void> tapOpen(WidgetTester tester, {bool endless = false}) async {
  await tester.tap(find.text('open'));
  await settle(tester, endless: endless);
}

/// Locale / theme combinations every golden covers.
const goldenVariants = <(String, Locale, bool)>[
  ('light_en', Locale('en'), false),
  ('light_ar', Locale('ar'), false),
  ('dark_en', Locale('en'), true),
  ('dark_ar', Locale('ar'), true),
];

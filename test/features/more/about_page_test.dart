import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/app_info/app_info.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/config/log_level.dart';
import 'package:riverpod_core/core/design_system/widgets/async/error_state.dart';
import 'package:riverpod_core/core/design_system/widgets/async/skeleton_list.dart';
import 'package:riverpod_core/core/review/review_service.dart';
import 'package:riverpod_core/core/sharing/share_service.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/features/more/presentation/pages/about_page.dart';

import '../../helpers/fake_native_backends.dart';
import '../../helpers/helpers.dart';

const _info = AppInfo(
  name: 'Demo',
  version: '1.4.2',
  buildNumber: '37',
  packageName: 'com.example.demo',
);

AppConfig _config(Flavor flavor) => AppConfig(
  flavor: flavor,
  appName: 'Demo',
  apiBaseUrl: 'https://api.example.test',
  connectTimeout: const Duration(seconds: 15),
  receiveTimeout: const Duration(seconds: 30),
  logLevel: LogLevel.off,
  enableCrashReporting: false,
  enableAnalytics: false,
);

class _Setup {
  _Setup({required this.share, required this.review, required this.prefs});

  final FakeShareBackend share;
  final FakeReviewBackend review;
  final PrefsStorage prefs;
}

Future<_Setup> _pump(
  WidgetTester tester, {
  Flavor flavor = Flavor.dev,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  double textScale = 1.0,
  Size size = defaultTestSize,
  AppInfoSource? source,
  bool settle = true,
}) async {
  final prefs = (await tester.runAsync(() => fakePrefsStorage()))!;
  final share = FakeShareBackend();
  final review = FakeReviewBackend(available: false);
  await pumpApp(
    tester,
    const AboutPage(),
    locale: locale,
    themeMode: themeMode,
    textScale: textScale,
    size: size,
    overrides: [
      appConfigProvider.overrideWithValue(_config(flavor)),
      appInfoSourceProvider.overrideWithValue(
        source ?? FakeAppInfoSource(_info),
      ),
      shareBackendProvider.overrideWithValue(share),
      reviewBackendProvider.overrideWithValue(review),
      prefsStorageProvider.overrideWith((ref) => Future.value(prefs)),
    ],
  );
  if (settle) await tester.pumpAndSettle();
  return _Setup(share: share, review: review, prefs: prefs);
}

void main() {
  testWidgets('shows name, version, build and flavor in dev', (tester) async {
    await _pump(tester);

    expect(find.text('About'), findsOneWidget);
    expect(find.text('Demo'), findsOneWidget);
    expect(find.text('1.4.2'), findsOneWidget);
    expect(find.text('37'), findsOneWidget);
    expect(find.byKey(const ValueKey('about-flavor')), findsOneWidget);
    expect(find.text('dev'), findsOneWidget);
  });

  testWidgets('staging shows the flavor, prod does not', (tester) async {
    await _pump(tester, flavor: Flavor.staging);
    expect(find.text('staging'), findsOneWidget);

    await _pump(tester, flavor: Flavor.prod);
    expect(find.byKey(const ValueKey('about-flavor')), findsNothing);
    expect(find.text('1.4.2'), findsOneWidget);
  });

  testWidgets('an empty build number hides the build row', (tester) async {
    await _pump(
      tester,
      source: FakeAppInfoSource(
        const AppInfo(
          name: 'Demo',
          version: '2.0.0',
          buildNumber: '',
          packageName: 'p',
        ),
      ),
    );

    expect(find.byKey(const ValueKey('about-build')), findsNothing);
  });

  testWidgets('licenses opens the license page', (tester) async {
    await _pump(tester);

    await tester.tap(find.byKey(const ValueKey('about-licenses')));
    await tester.pumpAndSettle();

    expect(find.byType(LicensePage), findsOneWidget);
  });

  testWidgets('share sends the localized message', (tester) async {
    final setup = await _pump(tester);

    await tester.tap(find.byKey(const ValueKey('about-share')));
    await tester.pumpAndSettle();

    expect(setup.share.texts, ['Check out Demo']);
  });

  testWidgets('a failed share shows an error message', (tester) async {
    final setup = await _pump(tester);
    setup.share.error = StateError('x');

    await tester.tap(find.byKey(const ValueKey('about-share')));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not complete that. Please try again.'),
      findsOneWidget,
    );
    await tester.pumpAndSettle(const Duration(seconds: 10));
  });

  testWidgets('rate opens the store listing', (tester) async {
    final setup = await _pump(tester);

    await tester.tap(find.byKey(const ValueKey('about-rate')));
    await tester.pumpAndSettle();

    expect(setup.review.storeListingCalls.length, 1);
  });

  testWidgets('loading shows a skeleton', (tester) async {
    final completer = Completer<AppInfo>();
    addTearDown(() => completer.complete(_info));
    await _pump(
      tester,
      source: _PendingSource(completer.future),
      settle: false,
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(SkeletonList), findsOneWidget);
    expect(find.text('1.4.2'), findsNothing);
  });

  testWidgets('an error shows retry, and retry recovers', (tester) async {
    final source = FakeAppInfoSource(_info, error: StateError('x'));
    await _pump(tester, source: source);

    expect(find.byType(ErrorState), findsOneWidget);

    source.error = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('1.4.2'), findsOneWidget);
  });

  testWidgets('arabic renders RTL with translated labels', (tester) async {
    await _pump(tester, locale: const Locale('ar'));

    expect(find.text('حول التطبيق'), findsOneWidget);
    expect(find.text('الإصدار'), findsOneWidget);
    expect(
      Directionality.of(
        tester.element(find.byKey(const ValueKey('about-page'))),
      ),
      TextDirection.rtl,
    );
  });

  testWidgets('survives text scale 2.0 on a phone', (tester) async {
    await _pump(tester, textScale: 2.0);

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('about-share')), findsOneWidget);
  });

  testWidgets('tablet keeps the content in a centered column', (tester) async {
    await _pump(tester, size: const Size(900, 900));

    final width = tester
        .getSize(find.byKey(const ValueKey('about-share')))
        .width;
    expect(width, lessThanOrEqualTo(720));
  });

  group('golden', () {
    const modes = [
      (name: 'light_en', locale: Locale('en'), dark: false),
      (name: 'dark_en', locale: Locale('en'), dark: true),
      (name: 'light_ar', locale: Locale('ar'), dark: false),
      (name: 'dark_ar', locale: Locale('ar'), dark: true),
    ];
    for (final mode in modes) {
      testWidgets('about_${mode.name}', (tester) async {
        await _pump(
          tester,
          locale: mode.locale,
          themeMode: mode.dark ? ThemeMode.dark : ThemeMode.light,
        );
        await expectLater(
          find.byKey(const ValueKey('about-page')),
          matchesGoldenFile('../../goldens/more/about_${mode.name}.png'),
        );
      });
    }

    testWidgets('about_tablet_en', (tester) async {
      await _pump(tester, size: const Size(900, 900));
      await expectLater(
        find.byKey(const ValueKey('about-page')),
        matchesGoldenFile('../../goldens/more/about_tablet_en.png'),
      );
    });
  });
}

class _PendingSource implements AppInfoSource {
  _PendingSource(this._future);

  final Future<AppInfo> _future;

  @override
  Future<AppInfo> load() => _future;
}

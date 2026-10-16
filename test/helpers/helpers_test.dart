import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/tokens/app_tokens.dart';

import 'helpers.dart';

final _greetingProvider = Provider<String>((ref) => 'real');

void main() {
  group('pumpApp', () {
    testWidgets('applies RTL for ar and LTR for en', (tester) async {
      late TextDirection direction;
      await pumpApp(
        tester,
        locale: const Locale('ar'),
        Builder(
          builder: (context) {
            direction = Directionality.of(context);
            return const SizedBox();
          },
        ),
      );
      expect(direction, TextDirection.rtl);

      await pumpApp(
        tester,
        Builder(
          builder: (context) {
            direction = Directionality.of(context);
            return const SizedBox();
          },
        ),
      );
      expect(direction, TextDirection.ltr);
    });

    testWidgets('applies the text scale clamped to 0.8-2.0', (tester) async {
      late double scaled;
      Widget probe() => Builder(
        builder: (context) {
          scaled = MediaQuery.textScalerOf(context).scale(10);
          return const SizedBox();
        },
      );

      await pumpApp(tester, textScale: 2, probe());
      expect(scaled, 20);

      await pumpApp(tester, textScale: 3, probe());
      expect(scaled, 20, reason: 'above 2.0 is clamped');

      await pumpApp(tester, textScale: 0.5, probe());
      expect(scaled, 8, reason: 'below 0.8 is clamped');
    });

    testWidgets('uses the requested theme mode and the design_system theme', (
      tester,
    ) async {
      late Brightness brightness;
      late AppTokens tokens;
      Widget probe() => Builder(
        builder: (context) {
          brightness = Theme.of(context).brightness;
          tokens = context.tokens;
          return const SizedBox();
        },
      );

      await pumpApp(tester, themeMode: ThemeMode.dark, probe());
      expect(brightness, Brightness.dark);
      expect(tokens.colors, AppTokens.dark.colors);

      await pumpApp(tester, probe());
      expect(brightness, Brightness.light);
      expect(tokens.colors, AppTokens.light.colors);
    });

    testWidgets('uses the requested window size', (tester) async {
      late Size size;
      await pumpApp(
        tester,
        size: const Size(800, 600),
        Builder(
          builder: (context) {
            size = MediaQuery.sizeOf(context);
            return const SizedBox();
          },
        ),
      );
      expect(size, const Size(800, 600));
    });

    testWidgets('loads translations for the requested locale', (tester) async {
      late String label;
      Widget probe() => Builder(
        builder: (context) {
          label = 'english'.tr();
          return const SizedBox();
        },
      );

      await pumpApp(tester, probe());
      expect(label, 'English');

      await pumpApp(tester, locale: const Locale('ar'), probe());
      expect(label, isNot('English'));
      expect(label, isNotEmpty);
    });

    testWidgets('applies provider overrides', (tester) async {
      await pumpApp(
        tester,
        overrides: [_greetingProvider.overrideWithValue('fake')],
        Consumer(
          builder: (context, ref, _) => Text(ref.watch(_greetingProvider)),
        ),
      );
      expect(find.text('fake'), findsOneWidget);
    });
  });

  group('createContainer', () {
    test('returns a usable container with overrides applied', () {
      final container = createContainer(
        overrides: [_greetingProvider.overrideWithValue('fake')],
      );
      expect(container.read(_greetingProvider), 'fake');
    });

    test('disposes the container when the test ends', () {
      var disposed = false;
      // tearDowns run last-in first-out: this one runs after the dispose.
      addTearDown(() => expect(disposed, isTrue));

      final container = createContainer();
      final probe = Provider<int>((ref) {
        ref.onDispose(() => disposed = true);
        return 1;
      });
      container.read(probe);
    });
  });

  group('FakeHttpAdapter', () {
    test('returns queued JSON and records the request', () async {
      final adapter = FakeHttpAdapter()..enqueueJson(200, {'ok': true});
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
        ..httpClientAdapter = adapter;

      final response = await dio.get<Map<String, dynamic>>('/users');

      expect(response.statusCode, 200);
      expect(response.data, {'ok': true});
      expect(adapter.requests, hasLength(1));
      expect(adapter.requests.single.path, '/users');
      expect(adapter.requests.single.method, 'GET');
    });

    test('replays queued responses in order', () async {
      final adapter = FakeHttpAdapter()
        ..enqueueJson(500, {'message': 'boom'})
        ..enqueueJson(200, {'ok': true});
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
        ..httpClientAdapter = adapter;

      await expectLater(dio.get<dynamic>('/a'), throwsA(isA<DioException>()));
      final second = await dio.get<dynamic>('/b');
      expect(second.data, {'ok': true});
      expect(adapter.requests.map((r) => r.path), ['/a', '/b']);
    });

    test('throws a queued error', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      );
      final adapter = FakeHttpAdapter()..enqueueError(error);
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
        ..httpClientAdapter = adapter;

      await expectLater(dio.get<dynamic>('/x'), throwsA(same(error)));
    });

    test('fails when no response is queued', () async {
      final adapter = FakeHttpAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
        ..httpClientAdapter = adapter;

      await expectLater(dio.get<dynamic>('/none'), throwsA(anything));
      expect(adapter.requests, hasLength(1));
    });
  });
}

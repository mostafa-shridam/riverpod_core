import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/config/log_level.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/network/dio_client.dart';
import 'package:riverpod_core/core/network/interceptors/auth_interceptor.dart';
import 'package:riverpod_core/core/network/interceptors/idempotency_interceptor.dart';
import 'package:riverpod_core/core/network/session_events.dart';
import 'package:riverpod_core/core/network/token_refresher.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';

import '../../helpers/helpers.dart';

/// Refresher that counts calls and stores a new token on success.
class _CountingRefresher implements AccessTokenRefresher {
  _CountingRefresher({this.fail = false, this.storage});

  final bool fail;
  final FakeSecureStorage? storage;
  int calls = 0;

  @override
  Future<String> refreshAccessToken() async {
    calls++;
    await Future<void>.delayed(Duration.zero);
    if (fail) {
      throw const UnauthorizedException(message: 'refresh rejected');
    }
    await storage?.write(SecureKeys.accessToken, 'new');
    return 'new';
  }
}

/// Answers by the Authorization header, so the order of concurrent requests
/// does not matter.
class _RoutingAdapter implements HttpClientAdapter {
  _RoutingAdapter(this.respond);

  final ResponseBody Function(RequestOptions options) respond;
  final List<RequestOptions> requests = [];

  /// Authorization header of each call, copied at call time: a replayed
  /// request reuses its RequestOptions, so the object changes later.
  final List<String?> sentAuth = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    sentAuth.add(options.headers['Authorization'] as String?);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

AppConfig _config({LogLevel logLevel = LogLevel.debug}) => AppConfig(
  flavor: Flavor.dev,
  appName: 'Test',
  apiBaseUrl: 'https://api.example.test',
  connectTimeout: const Duration(seconds: 15),
  receiveTimeout: const Duration(seconds: 30),
  logLevel: logLevel,
  enableCrashReporting: false,
  enableAnalytics: false,
);

ProviderContainer _container({
  required HttpClientAdapter adapter,
  FakeSecureStorage? storage,
  AccessTokenRefresher? refresher,
  List<String>? logs,
  LogLevel logLevel = LogLevel.debug,
  List<Duration>? sleeps,
}) {
  return createContainer(
    overrides: [
      appConfigProvider.overrideWithValue(_config(logLevel: logLevel)),
      httpClientAdapterProvider.overrideWithValue(adapter),
      secureStorageProvider.overrideWithValue(storage ?? FakeSecureStorage()),
      if (refresher != null)
        accessTokenRefresherProvider.overrideWithValue(refresher),
      if (logs != null) networkLogSinkProvider.overrideWithValue(logs.add),
      networkSleepProvider.overrideWithValue((delay) async {
        sleeps?.add(delay);
      }),
    ],
  );
}

void main() {
  group('dio client wiring', () {
    test('base URL and timeouts come from AppConfig', () {
      final container = _container(adapter: FakeHttpAdapter());
      final dio = container.read(dioProvider);
      expect(dio.options.baseUrl, 'https://api.example.test');
      expect(dio.options.connectTimeout, const Duration(seconds: 15));
      expect(dio.options.receiveTimeout, const Duration(seconds: 30));
    });

    test('the refresh client has no auth interceptor', () {
      final container = _container(adapter: FakeHttpAdapter());
      final refresh = container.read(refreshDioProvider);
      expect(refresh.interceptors.whereType<AuthInterceptor>(), isEmpty);
      expect(
        container.read(dioProvider).interceptors.whereType<AuthInterceptor>(),
        hasLength(1),
      );
    });

    test('auth header comes from secure storage', () async {
      final adapter = FakeHttpAdapter()..enqueueJson(200, {'ok': true});
      final storage = FakeSecureStorage({SecureKeys.accessToken: 'tok-1'});
      final dio = _container(
        adapter: adapter,
        storage: storage,
      ).read(dioProvider);

      await dio.get<dynamic>('/me');

      expect(adapter.requests.single.headers['Authorization'], 'Bearer tok-1');
    });

    test('skipAuth sends the request without the header', () async {
      final adapter = FakeHttpAdapter()..enqueueJson(200, {});
      final storage = FakeSecureStorage({SecureKeys.accessToken: 'tok-1'});
      final dio = _container(
        adapter: adapter,
        storage: storage,
      ).read(dioProvider);

      await dio.get<dynamic>(
        '/public',
        options: Options(extra: {AuthInterceptor.skipAuthKey: true}),
      );

      expect(
        adapter.requests.single.headers.containsKey('Authorization'),
        isFalse,
      );
    });
  });

  group('401 and refresh', () {
    test(
      'N concurrent 401s cause one refresh and every request is replayed',
      () async {
        final storage = FakeSecureStorage({SecureKeys.accessToken: 'old'});
        final refresher = _CountingRefresher(storage: storage);
        final adapter = _RoutingAdapter((options) {
          final ok = options.headers['Authorization'] == 'Bearer new';
          return ResponseBody.fromString(
            '{"n":"${options.path}"}',
            ok ? 200 : 401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });
        final dio = _container(
          adapter: adapter,
          storage: storage,
          refresher: refresher,
        ).read(dioProvider);

        final responses = await Future.wait([
          for (var i = 0; i < 5; i++) dio.get<dynamic>('/r$i'),
        ]);

        expect(refresher.calls, 1);
        expect(responses.map((r) => r.statusCode), everyElement(200));
        expect(adapter.sentAuth.where((a) => a == 'Bearer old'), hasLength(5));
        expect(adapter.sentAuth.where((a) => a == 'Bearer new'), hasLength(5));
      },
    );

    test('refresh failure ends the session and raises the signal', () async {
      final storage = FakeSecureStorage({
        SecureKeys.accessToken: 'old',
        SecureKeys.refreshToken: 'r',
      });
      final container = _container(
        adapter: FakeHttpAdapter()..enqueueJson(401, {}),
        storage: storage,
        refresher: _CountingRefresher(fail: true),
      );
      final session = container.read(sessionEventsProvider);
      final expired = session.expired.first;
      final dio = container.read(dioProvider);

      final error = await dio
          .get<dynamic>('/me')
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(error, isA<DioException>());
      expect((error as DioException).error, isA<UnauthorizedException>());
      await expectLater(expired, completion(isNull));
      expect(storage.values, isEmpty);
    });

    test('a 401 for an older token is replayed without a refresh', () async {
      final storage = FakeSecureStorage({SecureKeys.accessToken: 'old'});
      final refresher = _CountingRefresher();
      final adapter = _RoutingAdapter((options) {
        // Another request renews the token while this one is in flight.
        if (options.headers['Authorization'] == 'Bearer old') {
          storage.write(SecureKeys.accessToken, 'new');
          return ResponseBody.fromString(
            '{}',
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString(
          '{}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
      final dio = _container(
        adapter: adapter,
        storage: storage,
        refresher: refresher,
      ).read(dioProvider);

      final response = await dio.get<dynamic>('/me');

      expect(response.statusCode, 200);
      expect(refresher.calls, 0);
      expect(adapter.requests.last.headers['Authorization'], 'Bearer new');
    });
  });

  group('retry and backoff', () {
    test('no retry on 400, 404 or 409', () async {
      for (final status in [400, 404, 409]) {
        final adapter = FakeHttpAdapter()..enqueueJson(status, {});
        final dio = _container(adapter: adapter).read(dioProvider);

        await expectLater(
          dio.get<dynamic>('/x'),
          throwsA(isA<DioException>()),
          reason: 'status $status',
        );
        expect(adapter.requests, hasLength(1), reason: 'status $status');
      }
    });

    test('503 is retried with exponential backoff until it succeeds', () async {
      final sleeps = <Duration>[];
      final adapter = FakeHttpAdapter()
        ..enqueueJson(503, {})
        ..enqueueJson(503, {})
        ..enqueueJson(200, {'ok': true});
      final dio = _container(
        adapter: adapter,
        sleeps: sleeps,
      ).read(dioProvider);

      final response = await dio.get<dynamic>('/x');

      expect(response.statusCode, 200);
      expect(adapter.requests, hasLength(3));
      expect(sleeps, hasLength(2));
      // baseDelay 500 ms * 2^(n-1), plus jitter below baseDelay.
      expect(sleeps[0].inMilliseconds, inInclusiveRange(500, 999));
      expect(sleeps[1].inMilliseconds, inInclusiveRange(1000, 1499));
    });

    test('gives up after three attempts with a ServerException', () async {
      final adapter = FakeHttpAdapter()
        ..enqueueJson(503, {})
        ..enqueueJson(503, {})
        ..enqueueJson(503, {});
      final dio = _container(adapter: adapter, sleeps: []).read(dioProvider);

      final error = await dio
          .get<dynamic>('/x')
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(adapter.requests, hasLength(3));
      expect(
        (error as DioException).error,
        isA<ServerException>().having((e) => e.statusCode, 'status', 503),
      );
    });

    test('429 honors Retry-After', () async {
      final sleeps = <Duration>[];
      var calls = 0;
      final adapter = _RoutingAdapter((_) {
        calls++;
        return calls == 1
            ? ResponseBody.fromString(
                '{}',
                429,
                headers: {
                  'retry-after': ['2'],
                  Headers.contentTypeHeader: [Headers.jsonContentType],
                },
              )
            : ResponseBody.fromString(
                '{}',
                200,
                headers: {
                  Headers.contentTypeHeader: [Headers.jsonContentType],
                },
              );
      });
      final dio = _container(
        adapter: adapter,
        sleeps: sleeps,
      ).read(dioProvider);

      await dio.get<dynamic>('/x');

      expect(sleeps, [const Duration(seconds: 2)]);
    });

    test('a write retry reuses the same Idempotency-Key', () async {
      final adapter = FakeHttpAdapter()
        ..enqueueJson(503, {})
        ..enqueueJson(201, {'id': 1});
      final dio = _container(adapter: adapter, sleeps: []).read(dioProvider);

      await dio.post<dynamic>('/orders', data: {'a': 1});

      expect(adapter.requests, hasLength(2));
      final keys = adapter.requests
          .map((r) => r.headers[IdempotencyInterceptor.headerName])
          .toList();
      expect(keys.first, isNotNull);
      expect(keys.first, isNotEmpty);
      expect(keys[1], keys.first);
    });

    test('a caller-supplied Idempotency-Key is kept', () async {
      final adapter = FakeHttpAdapter()..enqueueJson(201, {});
      final dio = _container(adapter: adapter).read(dioProvider);

      await dio.post<dynamic>(
        '/orders',
        options: Options(
          headers: {IdempotencyInterceptor.headerName: 'caller-key'},
        ),
      );

      expect(
        adapter.requests.single.headers[IdempotencyInterceptor.headerName],
        'caller-key',
      );
    });
  });

  group('error mapping', () {
    test('mapped AppException is in DioException.error', () async {
      final adapter = FakeHttpAdapter()..enqueueJson(404, {});
      final dio = _container(adapter: adapter).read(dioProvider);

      await expectLater(
        dio.get<dynamic>('/x'),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<NotFoundException>(),
          ),
        ),
      );
    });

    test('a 400 with field errors becomes ValidationException', () async {
      final adapter = FakeHttpAdapter()
        ..enqueueJson(400, {
          'errors': {
            'email': ['taken'],
          },
        });
      final dio = _container(adapter: adapter).read(dioProvider);

      await expectLater(
        dio.post<dynamic>('/x', data: {}),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<ValidationException>().having(
              (v) => v.fieldErrors['email'],
              'email',
              ['taken'],
            ),
          ),
        ),
      );
    });

    test('a connection error becomes NetworkException after retries', () async {
      final adapter = FakeHttpAdapter();
      for (var i = 0; i < 3; i++) {
        adapter.enqueueError(const SocketException('offline'));
      }
      final dio = _container(adapter: adapter, sleeps: []).read(dioProvider);

      await expectLater(
        dio.get<dynamic>('/x'),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<NetworkException>(),
          ),
        ),
      );
      expect(adapter.requests, hasLength(3));
    });
  });

  group('logging', () {
    test('logs never contain the Authorization header or the token', () async {
      final logs = <String>[];
      final storage = FakeSecureStorage({
        SecureKeys.accessToken: 'secret-token-123',
      });
      final adapter = FakeHttpAdapter()
        ..enqueueJson(200, {'password': 'hunter2'})
        ..enqueueJson(404, {'password': 'hunter2'});
      final dio = _container(
        adapter: adapter,
        storage: storage,
        logs: logs,
      ).read(dioProvider);

      await dio.get<dynamic>('/me');
      await expectLater(
        dio.get<dynamic>('/missing'),
        throwsA(isA<DioException>()),
      );

      expect(logs, hasLength(2));
      for (final line in logs) {
        expect(line, isNot(contains('secret-token')));
        expect(line, isNot(contains('Authorization')));
        expect(line, isNot(contains('hunter2')));
      }
      expect(logs.first, contains('GET /me -> 200'));
    });

    test('nothing is logged below debug (prod)', () async {
      final logs = <String>[];
      final adapter = FakeHttpAdapter()..enqueueJson(200, {});
      final dio = _container(
        adapter: adapter,
        logs: logs,
        logLevel: LogLevel.warning,
      ).read(dioProvider);

      await dio.get<dynamic>('/me');

      expect(logs, isEmpty);
    });
  });
}

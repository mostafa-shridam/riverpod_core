import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/log_level.dart';
import 'package:riverpod_core/core/network/interceptors/auth_interceptor.dart';
import 'package:riverpod_core/core/network/interceptors/error_mapping_interceptor.dart';
import 'package:riverpod_core/core/network/interceptors/idempotency_interceptor.dart';
import 'package:riverpod_core/core/network/interceptors/logging_interceptor.dart';
import 'package:riverpod_core/core/network/interceptors/refresh_token_interceptor.dart';
import 'package:riverpod_core/core/network/interceptors/retry_backoff_interceptor.dart';
import 'package:riverpod_core/core/network/session_events.dart';
import 'package:riverpod_core/core/network/token_refresher.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';

part 'dio_client.g.dart';

/// Where request log lines go. Default: `dart:developer` (bootstrap replaces it
/// with the app logger).
typedef NetworkLogSink = void Function(String line);

/// The transport. Tests override it with a `FakeHttpAdapter`.
@Riverpod(keepAlive: true)
HttpClientAdapter httpClientAdapter(Ref ref) => IOHttpClientAdapter();

@Riverpod(keepAlive: true)
NetworkLogSink networkLogSink(Ref ref) {
  return (line) => developer.log(line, name: 'network');
}

/// Waits between retries. Tests override it so no real time passes.
@Riverpod(keepAlive: true)
Future<void> Function(Duration delay) networkSleep(Ref ref) {
  return (delay) => Future<void>.delayed(delay);
}

/// The app's one HTTP client. Features get it through repositories, never
/// build their own `Dio`.
///
/// Interceptors run in this order (NETWORKING.md): idempotency, auth, refresh,
/// retry/backoff, logging (debug only), error mapping (always last).
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final config = ref.watch(appConfigProvider);
  final storage = ref.watch(secureStorageProvider);
  // Single-flight: concurrent 401s share one refresh whatever refresher is bound.
  final refresher = SingleFlightRefresher(
    ref.watch(accessTokenRefresherProvider),
  );
  final session = ref.watch(sessionEventsProvider);
  final sink = ref.watch(networkLogSinkProvider);
  final sleep = ref.watch(networkSleepProvider);

  final client = _baseDio(config)
    ..httpClientAdapter = ref.watch(httpClientAdapterProvider);
  client.interceptors.addAll([
    IdempotencyInterceptor(),
    AuthInterceptor(storage),
    RefreshTokenInterceptor(
      dio: client,
      refresher: refresher,
      storage: storage,
      session: session,
    ),
    RetryBackoffInterceptor(dio: client, sleep: sleep),
    if (config.logLevel == LogLevel.debug) LoggingInterceptor(sink),
    const ErrorMappingInterceptor(),
  ]);
  ref.onDispose(client.close);
  return client;
}

/// Client for the refresh-token call only. It has no auth and no refresh
/// interceptor, so a 401 on the refresh call cannot recurse.
@Riverpod(keepAlive: true)
Dio refreshDio(Ref ref) {
  final config = ref.watch(appConfigProvider);
  final sink = ref.watch(networkLogSinkProvider);

  final client = _baseDio(config)
    ..httpClientAdapter = ref.watch(httpClientAdapterProvider);
  client.interceptors.addAll([
    if (config.logLevel == LogLevel.debug) LoggingInterceptor(sink),
    const ErrorMappingInterceptor(),
  ]);
  ref.onDispose(client.close);
  return client;
}

Dio _baseDio(AppConfig config) {
  return Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: config.connectTimeout,
      // AppConfig has no send timeout; sends use the receive timeout.
      sendTimeout: config.receiveTimeout,
      receiveTimeout: config.receiveTimeout,
      headers: const {'Accept': 'application/json'},
      contentType: 'application/json',
    ),
  );
}

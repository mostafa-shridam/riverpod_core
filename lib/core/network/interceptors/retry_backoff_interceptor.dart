import 'dart:async' as async;
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:riverpod_core/core/network/interceptors/idempotency_interceptor.dart';

/// Retries transient failures with exponential backoff and jitter.
///
/// - Only idempotent requests: GET, HEAD, PUT, DELETE, or any request that
///   carries an `Idempotency-Key`.
/// - Never `FormData` bodies (uploads are single-use streams).
/// - Only transient errors: connection and timeout errors, 429, 502, 503, 504.
///   Other 4xx are never retried.
/// - Delay before retry n is `baseDelay * 2^(n-1) + jitter` (jitter is below
///   `baseDelay`), or the `Retry-After` header when the server sends one.
class RetryBackoffInterceptor extends Interceptor {
  RetryBackoffInterceptor({
    required Dio dio,
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    Random? random,
    Future<void> Function(Duration delay)? sleep,
  }) : _dio = dio,
       _random = random ?? Random(),
       _sleep = sleep ?? Future.delayed;

  /// `RequestOptions.extra` key holding the attempt number (1-based).
  static const _attemptKey = 'retryAttempt';
  static const _idempotentMethods = {'GET', 'HEAD', 'PUT', 'DELETE'};
  static const _retryableStatuses = {429, 502, 503, 504};

  final Dio _dio;

  /// Total attempts, the first request included.
  final int maxAttempts;
  final Duration baseDelay;
  final Random _random;
  final Future<void> Function(Duration delay) _sleep;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_attemptKey] as int?) ?? 1;
    if (attempt >= maxAttempts || !_isRetryable(err)) {
      return handler.next(err);
    }

    await _sleep(_delayFor(err, attempt));
    options.extra[_attemptKey] = attempt + 1;
    try {
      // The same options object keeps the same Idempotency-Key.
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _isRetryable(DioException err) {
    if (!_isIdempotent(err.requestOptions)) return false;
    // A FormData body (uploads) is a one-shot stream: it cannot be sent twice.
    if (err.requestOptions.data is FormData) return false;
    switch (err.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      case DioExceptionType.badResponse:
        return _retryableStatuses.contains(err.response?.statusCode);
      case DioExceptionType.unknown:
        // Dio reports raw socket and timeout failures as unknown.
        final cause = err.error;
        return cause is SocketException || cause is async.TimeoutException;
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.transformTimeout:
        return false;
    }
  }

  bool _isIdempotent(RequestOptions options) {
    if (_idempotentMethods.contains(options.method.toUpperCase())) return true;
    return options.headers.keys.any(
      (name) =>
          name.toLowerCase() == IdempotencyInterceptor.headerName.toLowerCase(),
    );
  }

  Duration _delayFor(DioException err, int attempt) {
    final retryAfter = _retryAfter(err.response);
    if (retryAfter != null) return retryAfter;
    final exponential = baseDelay * (1 << (attempt - 1));
    final jitterMillis = baseDelay.inMilliseconds == 0
        ? 0
        : _random.nextInt(baseDelay.inMilliseconds);
    return exponential + Duration(milliseconds: jitterMillis);
  }

  Duration? _retryAfter(Response<dynamic>? response) {
    final raw = response?.headers.value('retry-after');
    final seconds = raw == null ? null : int.tryParse(raw.trim());
    return seconds == null ? null : Duration(seconds: seconds);
  }
}

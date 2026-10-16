import 'package:dio/dio.dart';

/// Writes one line per request: method, path, status or error type, duration.
///
/// Allow-list only: headers, query strings and bodies are never read, so
/// `Authorization`, tokens and passwords cannot reach the sink. The dio client
/// adds this interceptor only at log level debug (dev flavor).
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this._sink);

  static const _clockKey = 'logStopwatch';

  final void Function(String line) _sink;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_clockKey] = Stopwatch()..start();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final options = response.requestOptions;
    _sink(
      '${options.method} ${options.uri.path} -> '
      '${response.statusCode} in ${_elapsedMs(options)} ms',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final status = err.response?.statusCode;
    _sink(
      '${options.method} ${options.uri.path} failed: '
      '${err.type.name}${status == null ? '' : ' ($status)'} '
      'in ${_elapsedMs(options)} ms',
    );
    handler.next(err);
  }

  int _elapsedMs(RequestOptions options) {
    final clock = options.extra[_clockKey] as Stopwatch?;
    return clock?.elapsedMilliseconds ?? 0;
  }
}

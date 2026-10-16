import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// Adds an `Idempotency-Key` to every write unless the caller set one. The key
/// stays on the request, so retries of the same request reuse it.
class IdempotencyInterceptor extends Interceptor {
  IdempotencyInterceptor({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  static const headerName = 'Idempotency-Key';
  static const _writeMethods = {'POST', 'PUT', 'PATCH', 'DELETE'};

  final Uuid _uuid;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final isWrite = _writeMethods.contains(options.method.toUpperCase());
    final hasKey = options.headers.keys.any(
      (name) => name.toLowerCase() == headerName.toLowerCase(),
    );
    if (isWrite && !hasKey) {
      options.headers[headerName] = _uuid.v4();
    }
    handler.next(options);
  }
}

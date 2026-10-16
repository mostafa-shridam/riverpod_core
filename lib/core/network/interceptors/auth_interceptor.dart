import 'package:dio/dio.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';

/// Attaches `Authorization: Bearer <access token>` from secure storage.
/// Requests with `extra['skipAuth'] == true` are sent without it.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  /// `RequestOptions.extra` key that turns this interceptor off per request.
  static const skipAuthKey = 'skipAuth';

  final SecureStorage _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuthKey] == true) {
      return handler.next(options);
    }
    final token = await _storage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

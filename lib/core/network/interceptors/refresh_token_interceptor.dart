import 'package:dio/dio.dart';
import 'package:riverpod_core/core/network/interceptors/auth_interceptor.dart';
import 'package:riverpod_core/core/network/session_events.dart';
import 'package:riverpod_core/core/network/token_refresher.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';

/// On 401, renews the token once and replays the request.
///
/// - Concurrent 401s share one refresh (see [SingleFlightRefresher]).
/// - A 401 whose request carried an older token than the stored one is
///   replayed with the stored token, without another refresh.
/// - If the refresh fails, the tokens are cleared, [SessionEvents] is raised
///   and the original 401 is passed on (it maps to `UnauthorizedException`).
class RefreshTokenInterceptor extends Interceptor {
  RefreshTokenInterceptor({
    required Dio dio,
    required AccessTokenRefresher refresher,
    required SecureStorage storage,
    required SessionEvents session,
  }) : _dio = dio,
       _refresher = refresher,
       _storage = storage,
       _session = session;

  /// `RequestOptions.extra` flag set on a replayed request, so it cannot loop.
  static const _replayedKey = 'tokenReplayed';

  final Dio _dio;
  final AccessTokenRefresher _refresher;
  final SecureStorage _storage;
  final SessionEvents _session;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final isUnauthorized = err.response?.statusCode == 401;
    if (!isUnauthorized ||
        options.extra[AuthInterceptor.skipAuthKey] == true ||
        options.extra[_replayedKey] == true) {
      return handler.next(err);
    }

    final sentAuth = options.headers['Authorization'];
    final stored = await _storage.readAccessToken();
    // A request sent with an older token means another request already
    // renewed it, so it is replayed with the stored token.
    if (stored == null || stored.isEmpty || sentAuth == 'Bearer $stored') {
      try {
        await _refresher.refreshAccessToken();
      } catch (_) {
        await _endSession();
        return handler.next(err);
      }
    }

    options.extra[_replayedKey] = true;
    try {
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (replayError) {
      handler.next(replayError);
    }
  }

  Future<void> _endSession() async {
    await _storage.delete(SecureKeys.accessToken);
    await _storage.delete(SecureKeys.refreshToken);
    _session.notifyExpired();
  }
}

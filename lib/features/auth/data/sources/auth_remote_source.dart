import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/auth/auth_endpoints.dart';
import 'package:riverpod_core/core/network/dio_client.dart';
import 'package:riverpod_core/features/auth/data/models/auth_requests.dart';
import 'package:riverpod_core/features/auth/data/models/auth_session.dart';
import 'package:riverpod_core/features/auth/data/sources/auth_mock_source.dart';

part 'auth_remote_source.g.dart';

/// Talks to the auth endpoints. Throws `DioException` (its `error` is an
/// `AppException`) or an `AppException`; the repository maps everything once.
abstract interface class AuthRemoteSource {
  Future<AuthSession> login(LoginRequest request);

  Future<AuthSession> register(RegisterRequest request);

  Future<void> forgotPassword(String email);

  Future<void> logout();
}

/// The real source over Dio.
class HttpAuthRemoteSource implements AuthRemoteSource {
  HttpAuthRemoteSource(this._dio);

  final Dio _dio;

  @override
  Future<AuthSession> login(LoginRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      AuthEndpoints.login,
      data: request.toJson(),
    );
    return AuthSession.fromJson(response.data ?? const {});
  }

  @override
  Future<AuthSession> register(RegisterRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      AuthEndpoints.register,
      data: request.toJson(),
    );
    return AuthSession.fromJson(response.data ?? const {});
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _dio.post<void>(AuthEndpoints.forgotPassword, data: {'email': email});
  }

  @override
  Future<void> logout() async {
    await _dio.post<void>(AuthEndpoints.logout);
  }
}

/// The source the app uses: the mock while [authUseMockSource] is on.
@Riverpod(keepAlive: true)
AuthRemoteSource authRemoteSource(Ref ref) {
  if (authUseMockSource) return MockAuthSource();
  return HttpAuthRemoteSource(ref.watch(dioProvider));
}

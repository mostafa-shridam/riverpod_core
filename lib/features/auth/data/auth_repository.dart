import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/errors/error_mapper.dart';
import 'package:riverpod_core/features/auth/data/models/auth_requests.dart';
import 'package:riverpod_core/features/auth/data/models/auth_session.dart';
import 'package:riverpod_core/features/auth/data/sources/auth_remote_source.dart';

part 'auth_repository.g.dart';

/// Auth use cases for the UI. Every failure leaves as an `AppException`.
class AuthRepository {
  AuthRepository(this._source);

  final AuthRemoteSource _source;

  Future<AuthSession> login({required String email, required String password}) {
    return _mapped(
      () => _source.login(LoginRequest(email: email, password: password)),
    );
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _mapped(
      () => _source.register(
        RegisterRequest(name: name, email: email, password: password),
      ),
    );
  }

  Future<void> forgotPassword(String email) {
    return _mapped(() => _source.forgotPassword(email));
  }

  /// Best effort on the server; the session wipe does not depend on it.
  Future<void> logout() => _mapped(_source.logout);

  Future<T> _mapped<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (error, stackTrace) {
      throw mapError(error, stackTrace);
    }
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(authRemoteSourceProvider));
}

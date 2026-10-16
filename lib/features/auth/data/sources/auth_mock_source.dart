import 'package:riverpod_core/core/auth/auth_tokens.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/features/auth/data/models/auth_requests.dart';
import 'package:riverpod_core/features/auth/data/models/auth_session.dart';
import 'package:riverpod_core/features/auth/data/sources/auth_remote_source.dart';
import 'package:riverpod_core/shared/models/auth_user.dart';

/// In-memory auth source for running without a backend. Rules, so every
/// state can be tried:
/// - a password shorter than 6 characters is a validation error;
/// - the address `wrong@example.com` is rejected as unauthorized;
/// - `taken@example.com` cannot register (field error on email);
/// - `missing@example.com` has no account for forgot-password;
/// - anything else signs in or registers.
class MockAuthSource implements AuthRemoteSource {
  static const _delay = Duration(milliseconds: 400);

  @override
  Future<AuthSession> login(LoginRequest request) async {
    await Future<void>.delayed(_delay);
    if (request.email == 'wrong@example.com') {
      throw const UnauthorizedException(message: 'Wrong credentials');
    }
    return _session(email: request.email, name: request.email.split('@').first);
  }

  @override
  Future<AuthSession> register(RegisterRequest request) async {
    await Future<void>.delayed(_delay);
    if (request.email == 'taken@example.com') {
      throw const ValidationException(
        fieldErrors: {
          'email': ['Already registered'],
        },
      );
    }
    return _session(email: request.email, name: request.name);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future<void>.delayed(_delay);
    if (email == 'missing@example.com') {
      throw const NotFoundException(message: 'No account for this email');
    }
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(_delay);
  }

  AuthSession _session({required String email, required String name}) {
    return AuthSession(
      tokens: AuthTokens(
        accessToken: 'mock-access-${DateTime.now().microsecondsSinceEpoch}',
        refreshToken: 'mock-refresh-$email',
      ),
      user: AuthUser(id: email, email: email, name: name),
    );
  }
}

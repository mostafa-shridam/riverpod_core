import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/features/auth/data/auth_repository.dart';
import 'package:riverpod_core/features/auth/data/sources/auth_mock_source.dart';

void main() {
  late AuthRepository repository;

  setUp(() {
    repository = AuthRepository(MockAuthSource());
  });

  test('a normal login returns the tokens and the user', () async {
    final session = await repository.login(
      email: 'ana@example.com',
      password: 'secret1',
    );

    expect(session.user.email, 'ana@example.com');
    expect(session.user.name, 'ana');
    expect(session.tokens.accessToken, startsWith('mock-access-'));
  });

  test('a rejected login surfaces as UnauthorizedException', () async {
    await expectLater(
      repository.login(email: 'wrong@example.com', password: 'secret1'),
      throwsA(isA<UnauthorizedException>()),
    );
  });

  test('a taken address surfaces a field error on email', () async {
    await expectLater(
      repository.register(
        name: 'Ana',
        email: 'taken@example.com',
        password: 'secret1',
      ),
      throwsA(
        isA<ValidationException>().having(
          (e) => e.firstMessageFor('email'),
          'email',
          isNotNull,
        ),
      ),
    );
  });

  test('forgot-password for an unknown address is NotFound', () async {
    await expectLater(
      repository.forgotPassword('missing@example.com'),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('logout completes', () async {
    await repository.logout();
  });
}

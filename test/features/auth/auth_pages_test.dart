import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';
import 'package:riverpod_core/features/auth/data/models/auth_requests.dart';
import 'package:riverpod_core/features/auth/data/models/auth_session.dart';
import 'package:riverpod_core/features/auth/data/sources/auth_remote_source.dart';
import 'package:riverpod_core/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:riverpod_core/features/auth/presentation/pages/login_page.dart';
import 'package:riverpod_core/features/auth/presentation/pages/register_page.dart';

import '../../helpers/helpers.dart';
import 'auth_harness.dart';

class _Source implements AuthRemoteSource {
  _Source({this.loginError});

  final AppException? loginError;

  @override
  Future<AuthSession> login(LoginRequest request) async {
    if (loginError != null) throw loginError!;
    throw UnimplementedError();
  }

  @override
  Future<AuthSession> register(RegisterRequest request) async =>
      throw UnimplementedError();

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> logout() async {}
}

List<Override> _overrides({AppException? loginError}) => [
  authRemoteSourceProvider.overrideWithValue(_Source(loginError: loginError)),
  secureStorageProvider.overrideWithValue(FakeSecureStorage()),
];

const networkMessage =
    'No internet connection. Check your network and try again.';

void main() {
  group('LoginPage', () {
    testWidgets('shows the fields and actions', (tester) async {
      await pumpAuthPage(tester, const LoginPage(), overrides: _overrides());

      expect(find.text('Sign in'), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('Create an account'), findsOneWidget);
    });

    testWidgets('empty submit shows the required message', (tester) async {
      await pumpAuthPage(tester, const LoginPage(), overrides: _overrides());

      await tester.tap(find.widgetWithText(AppButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('This field is required'), findsWidgets);
    });

    testWidgets('a bad email shows the invalid-email message', (tester) async {
      await pumpAuthPage(tester, const LoginPage(), overrides: _overrides());

      await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
      await tester.tap(find.widgetWithText(AppButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('a field error from the server is shown on that field', (
      tester,
    ) async {
      await pumpAuthPage(
        tester,
        const LoginPage(),
        overrides: _overrides(
          loginError: const ValidationException(
            fieldErrors: {
              'email': ['Account is locked'],
            },
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField).first,
        'ana@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'secret1');
      await tester.tap(find.widgetWithText(AppButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Account is locked'), findsOneWidget);
    });

    testWidgets('a network error is announced in a snackbar', (tester) async {
      await pumpAuthPage(
        tester,
        const LoginPage(),
        overrides: _overrides(loginError: const NetworkException()),
      );

      await tester.enterText(
        find.byType(TextFormField).first,
        'ana@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'secret1');
      await tester.tap(find.widgetWithText(AppButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text(networkMessage), findsOneWidget);
    });

    testWidgets('renders in Arabic with the right direction', (tester) async {
      await pumpAuthPage(
        tester,
        const LoginPage(),
        overrides: _overrides(),
        locale: const Locale('ar'),
      );

      expect(
        Directionality.of(tester.element(find.byType(LoginPage))),
        TextDirection.rtl,
      );
    });
  });

  testWidgets('RegisterPage shows name, email and password', (tester) async {
    await pumpAuthPage(tester, const RegisterPage(), overrides: _overrides());

    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('ForgotPasswordPage asks for the email', (tester) async {
    await pumpAuthPage(
      tester,
      const ForgotPasswordPage(),
      overrides: _overrides(),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Send reset link'), findsOneWidget);
  });
}

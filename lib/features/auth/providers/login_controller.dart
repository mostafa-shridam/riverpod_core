import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/errors/error_mapper.dart';
import 'package:riverpod_core/features/auth/data/auth_repository.dart';

part 'login_controller.g.dart';

/// Sign-in form state. Success hands the session to [SessionController]; the
/// router then leaves the login page.
@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {}

  Future<void> submit({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      // Set before signing in: signing in redirects away and disposes this.
      state = const AsyncData(null);
      await ref
          .read(sessionControllerProvider.notifier)
          .signIn(tokens: session.tokens, user: session.user);
    } catch (error, stackTrace) {
      state = AsyncError(mapError(error, stackTrace), stackTrace);
    }
  }
}

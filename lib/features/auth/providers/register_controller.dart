import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/errors/error_mapper.dart';
import 'package:riverpod_core/features/auth/data/auth_repository.dart';

part 'register_controller.g.dart';

/// Registration form state. Success signs the new user in.
@riverpod
class RegisterController extends _$RegisterController {
  @override
  FutureOr<void> build() {}

  Future<void> submit({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .register(name: name, email: email, password: password);
      state = const AsyncData(null);
      await ref
          .read(sessionControllerProvider.notifier)
          .signIn(tokens: session.tokens, user: session.user);
    } catch (error, stackTrace) {
      state = AsyncError(mapError(error, stackTrace), stackTrace);
    }
  }
}

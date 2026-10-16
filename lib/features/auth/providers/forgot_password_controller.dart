import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/errors/error_mapper.dart';
import 'package:riverpod_core/features/auth/data/auth_repository.dart';

part 'forgot_password_controller.g.dart';

/// Forgot-password form state. Success only means the request was accepted.
@riverpod
class ForgotPasswordController extends _$ForgotPasswordController {
  @override
  FutureOr<void> build() {}

  Future<void> submit(String email) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).forgotPassword(email);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(mapError(error, stackTrace), stackTrace);
    }
  }
}

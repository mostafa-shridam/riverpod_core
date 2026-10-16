// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Forgot-password form state. Success only means the request was accepted.

@ProviderFor(ForgotPasswordController)
final forgotPasswordControllerProvider = ForgotPasswordControllerProvider._();

/// Forgot-password form state. Success only means the request was accepted.
final class ForgotPasswordControllerProvider
    extends $AsyncNotifierProvider<ForgotPasswordController, void> {
  /// Forgot-password form state. Success only means the request was accepted.
  ForgotPasswordControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forgotPasswordControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forgotPasswordControllerHash();

  @$internal
  @override
  ForgotPasswordController create() => ForgotPasswordController();
}

String _$forgotPasswordControllerHash() =>
    r'a239688484a511c9bf3ab674d2cb7ec408732883';

/// Forgot-password form state. Success only means the request was accepted.

abstract class _$ForgotPasswordController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

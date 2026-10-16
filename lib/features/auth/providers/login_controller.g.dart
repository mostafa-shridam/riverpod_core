// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sign-in form state. Success hands the session to [SessionController]; the
/// router then leaves the login page.

@ProviderFor(LoginController)
final loginControllerProvider = LoginControllerProvider._();

/// Sign-in form state. Success hands the session to [SessionController]; the
/// router then leaves the login page.
final class LoginControllerProvider
    extends $AsyncNotifierProvider<LoginController, void> {
  /// Sign-in form state. Success hands the session to [SessionController]; the
  /// router then leaves the login page.
  LoginControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginControllerHash();

  @$internal
  @override
  LoginController create() => LoginController();
}

String _$loginControllerHash() => r'85f09abef172260a1f80e5a6c7e0f3d3c8097ec2';

/// Sign-in form state. Success hands the session to [SessionController]; the
/// router then leaves the login page.

abstract class _$LoginController extends $AsyncNotifier<void> {
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in user, or null. Kept apart from [SessionStatus] so guards
/// only watch the status.

@ProviderFor(SessionUser)
final sessionUserProvider = SessionUserProvider._();

/// The signed-in user, or null. Kept apart from [SessionStatus] so guards
/// only watch the status.
final class SessionUserProvider
    extends $NotifierProvider<SessionUser, AuthUser?> {
  /// The signed-in user, or null. Kept apart from [SessionStatus] so guards
  /// only watch the status.
  SessionUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionUserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionUserHash();

  @$internal
  @override
  SessionUser create() => SessionUser();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthUser? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthUser?>(value),
    );
  }
}

String _$sessionUserHash() => r'cf7db2fbb93ecf6b7108af92da1d6c54faf4f236';

/// The signed-in user, or null. Kept apart from [SessionStatus] so guards
/// only watch the status.

abstract class _$SessionUser extends $Notifier<AuthUser?> {
  AuthUser? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthUser?, AuthUser?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthUser?, AuthUser?>,
              AuthUser?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Single owner of the session. Guards read the [SessionStatus]. The
/// controller is also the app's [AccessTokenRefresher], so the Dio refresh
/// works through it.

@ProviderFor(SessionController)
final sessionControllerProvider = SessionControllerProvider._();

/// Single owner of the session. Guards read the [SessionStatus]. The
/// controller is also the app's [AccessTokenRefresher], so the Dio refresh
/// works through it.
final class SessionControllerProvider
    extends $NotifierProvider<SessionController, SessionStatus> {
  /// Single owner of the session. Guards read the [SessionStatus]. The
  /// controller is also the app's [AccessTokenRefresher], so the Dio refresh
  /// works through it.
  SessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionControllerHash();

  @$internal
  @override
  SessionController create() => SessionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionStatus>(value),
    );
  }
}

String _$sessionControllerHash() => r'58769894f66f3abf80a9656ff635423c1a2d73c1';

/// Single owner of the session. Guards read the [SessionStatus]. The
/// controller is also the app's [AccessTokenRefresher], so the Dio refresh
/// works through it.

abstract class _$SessionController extends $Notifier<SessionStatus> {
  SessionStatus build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SessionStatus, SessionStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SessionStatus, SessionStatus>,
              SessionStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

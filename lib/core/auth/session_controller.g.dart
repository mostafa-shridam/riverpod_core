// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Single owner of the session state that routing guards read.
///
/// STUB (C-11): C-17 replaces the sign-in flow and the startup restore. It
/// already consumes [SessionEvents.expired]: an expired session signs out.

@ProviderFor(SessionController)
final sessionControllerProvider = SessionControllerProvider._();

/// Single owner of the session state that routing guards read.
///
/// STUB (C-11): C-17 replaces the sign-in flow and the startup restore. It
/// already consumes [SessionEvents.expired]: an expired session signs out.
final class SessionControllerProvider
    extends $NotifierProvider<SessionController, SessionStatus> {
  /// Single owner of the session state that routing guards read.
  ///
  /// STUB (C-11): C-17 replaces the sign-in flow and the startup restore. It
  /// already consumes [SessionEvents.expired]: an expired session signs out.
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

String _$sessionControllerHash() => r'cad0a1a3d373eecbaed422f36bd3553de99be062';

/// Single owner of the session state that routing guards read.
///
/// STUB (C-11): C-17 replaces the sign-in flow and the startup restore. It
/// already consumes [SessionEvents.expired]: an expired session signs out.

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

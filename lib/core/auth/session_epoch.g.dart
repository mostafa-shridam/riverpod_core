// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_epoch.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Counts sign-outs. Logout bumps it; providers that hold user data watch it
/// (`ref.watch(sessionEpochProvider)`) and rebuild, so no user data survives
/// a sign-out. This is the session invalidation mechanism, chosen over a
/// root container reset because it needs no change to `ProviderScope`.

@ProviderFor(SessionEpoch)
final sessionEpochProvider = SessionEpochProvider._();

/// Counts sign-outs. Logout bumps it; providers that hold user data watch it
/// (`ref.watch(sessionEpochProvider)`) and rebuild, so no user data survives
/// a sign-out. This is the session invalidation mechanism, chosen over a
/// root container reset because it needs no change to `ProviderScope`.
final class SessionEpochProvider extends $NotifierProvider<SessionEpoch, int> {
  /// Counts sign-outs. Logout bumps it; providers that hold user data watch it
  /// (`ref.watch(sessionEpochProvider)`) and rebuild, so no user data survives
  /// a sign-out. This is the session invalidation mechanism, chosen over a
  /// root container reset because it needs no change to `ProviderScope`.
  SessionEpochProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionEpochProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionEpochHash();

  @$internal
  @override
  SessionEpoch create() => SessionEpoch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$sessionEpochHash() => r'0c3db6ed6998d232ba29c8489eb32d468e8fb136';

/// Counts sign-outs. Logout bumps it; providers that hold user data watch it
/// (`ref.watch(sessionEpochProvider)`) and rebuild, so no user data survives
/// a sign-out. This is the session invalidation mechanism, chosen over a
/// root container reset because it needs no change to `ProviderScope`.

abstract class _$SessionEpoch extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

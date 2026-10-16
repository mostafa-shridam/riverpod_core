// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Online/offline status: the current value first, then each change. Repeated
/// identical statuses are dropped. While the first check runs the value is
/// loading, which readers should treat as online.

@ProviderFor(connectivity)
final connectivityProvider = ConnectivityProvider._();

/// Online/offline status: the current value first, then each change. Repeated
/// identical statuses are dropped. While the first check runs the value is
/// loading, which readers should treat as online.

final class ConnectivityProvider
    extends
        $FunctionalProvider<
          AsyncValue<ConnectivityStatus>,
          ConnectivityStatus,
          Stream<ConnectivityStatus>
        >
    with
        $FutureModifier<ConnectivityStatus>,
        $StreamProvider<ConnectivityStatus> {
  /// Online/offline status: the current value first, then each change. Repeated
  /// identical statuses are dropped. While the first check runs the value is
  /// loading, which readers should treat as online.
  ConnectivityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityHash();

  @$internal
  @override
  $StreamProviderElement<ConnectivityStatus> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ConnectivityStatus> create(Ref ref) {
    return connectivity(ref);
  }
}

String _$connectivityHash() => r'13afcd77859e64f02634bc00f52eca8cea50f014';

/// Emits an incrementing counter each time the device goes from offline back
/// to online. A counter (not `void`) because providers drop equal values, so
/// a second reconnect would otherwise be invisible to listeners.

@ProviderFor(backOnline)
final backOnlineProvider = BackOnlineProvider._();

/// Emits an incrementing counter each time the device goes from offline back
/// to online. A counter (not `void`) because providers drop equal values, so
/// a second reconnect would otherwise be invisible to listeners.

final class BackOnlineProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Emits an incrementing counter each time the device goes from offline back
  /// to online. A counter (not `void`) because providers drop equal values, so
  /// a second reconnect would otherwise be invisible to listeners.
  BackOnlineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backOnlineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backOnlineHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return backOnline(ref);
  }
}

String _$backOnlineHash() => r'381d661ef2c8165495c35784f2a057cd9d74e05f';

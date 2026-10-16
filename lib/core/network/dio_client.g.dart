// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The transport. Tests override it with a `FakeHttpAdapter`.

@ProviderFor(httpClientAdapter)
final httpClientAdapterProvider = HttpClientAdapterProvider._();

/// The transport. Tests override it with a `FakeHttpAdapter`.

final class HttpClientAdapterProvider
    extends
        $FunctionalProvider<
          HttpClientAdapter,
          HttpClientAdapter,
          HttpClientAdapter
        >
    with $Provider<HttpClientAdapter> {
  /// The transport. Tests override it with a `FakeHttpAdapter`.
  HttpClientAdapterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'httpClientAdapterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$httpClientAdapterHash();

  @$internal
  @override
  $ProviderElement<HttpClientAdapter> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HttpClientAdapter create(Ref ref) {
    return httpClientAdapter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HttpClientAdapter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HttpClientAdapter>(value),
    );
  }
}

String _$httpClientAdapterHash() => r'29344c4084e67b84a3be3c3daae484f9cf9b544f';

@ProviderFor(networkLogSink)
final networkLogSinkProvider = NetworkLogSinkProvider._();

final class NetworkLogSinkProvider
    extends $FunctionalProvider<NetworkLogSink, NetworkLogSink, NetworkLogSink>
    with $Provider<NetworkLogSink> {
  NetworkLogSinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkLogSinkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkLogSinkHash();

  @$internal
  @override
  $ProviderElement<NetworkLogSink> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NetworkLogSink create(Ref ref) {
    return networkLogSink(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkLogSink value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkLogSink>(value),
    );
  }
}

String _$networkLogSinkHash() => r'80f064fa0c8a247a772a32c97cc973f608124986';

/// Waits between retries. Tests override it so no real time passes.

@ProviderFor(networkSleep)
final networkSleepProvider = NetworkSleepProvider._();

/// Waits between retries. Tests override it so no real time passes.

final class NetworkSleepProvider
    extends
        $FunctionalProvider<
          Future<void> Function(Duration delay),
          Future<void> Function(Duration delay),
          Future<void> Function(Duration delay)
        >
    with $Provider<Future<void> Function(Duration delay)> {
  /// Waits between retries. Tests override it so no real time passes.
  NetworkSleepProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkSleepProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkSleepHash();

  @$internal
  @override
  $ProviderElement<Future<void> Function(Duration delay)> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Future<void> Function(Duration delay) create(Ref ref) {
    return networkSleep(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<void> Function(Duration delay) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Future<void> Function(Duration delay)>(value),
    );
  }
}

String _$networkSleepHash() => r'b63ee18f11ed3912f0aa9b3306127f6849675a56';

/// The app's one HTTP client. Features get it through repositories, never
/// build their own `Dio`.
///
/// Interceptors run in this order (NETWORKING.md): idempotency, auth, refresh,
/// retry/backoff, logging (debug only), error mapping (always last).

@ProviderFor(dio)
final dioProvider = DioProvider._();

/// The app's one HTTP client. Features get it through repositories, never
/// build their own `Dio`.
///
/// Interceptors run in this order (NETWORKING.md): idempotency, auth, refresh,
/// retry/backoff, logging (debug only), error mapping (always last).

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// The app's one HTTP client. Features get it through repositories, never
  /// build their own `Dio`.
  ///
  /// Interceptors run in this order (NETWORKING.md): idempotency, auth, refresh,
  /// retry/backoff, logging (debug only), error mapping (always last).
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'58af79af0640a1febdb58f8bf536b74c596fdaf7';

/// Client for the refresh-token call only. It has no auth and no refresh
/// interceptor, so a 401 on the refresh call cannot recurse.

@ProviderFor(refreshDio)
final refreshDioProvider = RefreshDioProvider._();

/// Client for the refresh-token call only. It has no auth and no refresh
/// interceptor, so a 401 on the refresh call cannot recurse.

final class RefreshDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Client for the refresh-token call only. It has no auth and no refresh
  /// interceptor, so a 401 on the refresh call cannot recurse.
  RefreshDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refreshDioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refreshDioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return refreshDio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$refreshDioHash() => r'88685cc37ebd4297a112f7f44a6f4fcc1d281a54';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_route_observer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The screen-view observer. Add it to the GoRouter `observers`.

@ProviderFor(analyticsRouteObserver)
final analyticsRouteObserverProvider = AnalyticsRouteObserverProvider._();

/// The screen-view observer. Add it to the GoRouter `observers`.

final class AnalyticsRouteObserverProvider
    extends
        $FunctionalProvider<
          AnalyticsRouteObserver,
          AnalyticsRouteObserver,
          AnalyticsRouteObserver
        >
    with $Provider<AnalyticsRouteObserver> {
  /// The screen-view observer. Add it to the GoRouter `observers`.
  AnalyticsRouteObserverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsRouteObserverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsRouteObserverHash();

  @$internal
  @override
  $ProviderElement<AnalyticsRouteObserver> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AnalyticsRouteObserver create(Ref ref) {
    return analyticsRouteObserver(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsRouteObserver value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsRouteObserver>(value),
    );
  }
}

String _$analyticsRouteObserverHash() =>
    r'c5e2241faba3f1c50101cdb94cef9d6fb48d7e75';

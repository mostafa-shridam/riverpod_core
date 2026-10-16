// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_router_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The one [NotificationRouter]. Taps wait in its queue until the app router
/// is attached and the user is signed in; `routeForDeepLink` is the route map.

@ProviderFor(notificationRouter)
final notificationRouterProvider = NotificationRouterProvider._();

/// The one [NotificationRouter]. Taps wait in its queue until the app router
/// is attached and the user is signed in; `routeForDeepLink` is the route map.

final class NotificationRouterProvider
    extends
        $FunctionalProvider<
          NotificationRouter,
          NotificationRouter,
          NotificationRouter
        >
    with $Provider<NotificationRouter> {
  /// The one [NotificationRouter]. Taps wait in its queue until the app router
  /// is attached and the user is signed in; `routeForDeepLink` is the route map.
  NotificationRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationRouterHash();

  @$internal
  @override
  $ProviderElement<NotificationRouter> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationRouter create(Ref ref) {
    return notificationRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationRouter>(value),
    );
  }
}

String _$notificationRouterHash() =>
    r'f64a7f8bed6004eff6cd5f0d983eb37bdb6b9331';

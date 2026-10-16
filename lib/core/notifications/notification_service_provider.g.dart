// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The one [NotificationService] of the app. It follows the session: sign-in
/// registers the push token; a sign-out that was not preceded by an explicit
/// `notificationLogoutProvider` call still cleans up locally.

@ProviderFor(notificationService)
final notificationServiceProvider = NotificationServiceProvider._();

/// The one [NotificationService] of the app. It follows the session: sign-in
/// registers the push token; a sign-out that was not preceded by an explicit
/// `notificationLogoutProvider` call still cleans up locally.

final class NotificationServiceProvider
    extends
        $FunctionalProvider<
          NotificationService,
          NotificationService,
          NotificationService
        >
    with $Provider<NotificationService> {
  /// The one [NotificationService] of the app. It follows the session: sign-in
  /// registers the push token; a sign-out that was not preceded by an explicit
  /// `notificationLogoutProvider` call still cleans up locally.
  NotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationService create(Ref ref) {
    return notificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationService>(value),
    );
  }
}

String _$notificationServiceHash() =>
    r'd2bf47fb52dc7863f894a0c998baa555b7f46ad4';

/// The logout hook for the auth feature: call and await it BEFORE
/// `clearUserData`, while the session can still authorize the server call that
/// unregisters this device from push.
///
/// ```dart
/// await ref.read(notificationLogoutProvider)();
/// await clearUserData(...);
/// ```

@ProviderFor(notificationLogout)
final notificationLogoutProvider = NotificationLogoutProvider._();

/// The logout hook for the auth feature: call and await it BEFORE
/// `clearUserData`, while the session can still authorize the server call that
/// unregisters this device from push.
///
/// ```dart
/// await ref.read(notificationLogoutProvider)();
/// await clearUserData(...);
/// ```

final class NotificationLogoutProvider
    extends
        $FunctionalProvider<
          Future<void> Function(),
          Future<void> Function(),
          Future<void> Function()
        >
    with $Provider<Future<void> Function()> {
  /// The logout hook for the auth feature: call and await it BEFORE
  /// `clearUserData`, while the session can still authorize the server call that
  /// unregisters this device from push.
  ///
  /// ```dart
  /// await ref.read(notificationLogoutProvider)();
  /// await clearUserData(...);
  /// ```
  NotificationLogoutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationLogoutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationLogoutHash();

  @$internal
  @override
  $ProviderElement<Future<void> Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Future<void> Function() create(Ref ref) {
    return notificationLogout(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<void> Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Future<void> Function()>(value),
    );
  }
}

String _$notificationLogoutHash() =>
    r'669b3d9af8a9b4fe8f6bd2ffbf1a98395d36f59b';

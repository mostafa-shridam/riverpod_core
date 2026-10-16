// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The clock of the notification system: override in tests.

@ProviderFor(notificationClock)
final notificationClockProvider = NotificationClockProvider._();

/// The clock of the notification system: override in tests.

final class NotificationClockProvider
    extends
        $FunctionalProvider<
          DateTime Function(),
          DateTime Function(),
          DateTime Function()
        >
    with $Provider<DateTime Function()> {
  /// The clock of the notification system: override in tests.
  NotificationClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationClockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationClockHash();

  @$internal
  @override
  $ProviderElement<DateTime Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DateTime Function() create(Ref ref) {
    return notificationClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime Function()>(value),
    );
  }
}

String _$notificationClockHash() => r'05c1e397713fc48ad162fc8f43798877483067c3';

/// Resolves a `LocaleKeys` constant in the current language.

@ProviderFor(notificationLabelResolver)
final notificationLabelResolverProvider = NotificationLabelResolverProvider._();

/// Resolves a `LocaleKeys` constant in the current language.

final class NotificationLabelResolverProvider
    extends
        $FunctionalProvider<
          NotificationLabelResolver,
          NotificationLabelResolver,
          NotificationLabelResolver
        >
    with $Provider<NotificationLabelResolver> {
  /// Resolves a `LocaleKeys` constant in the current language.
  NotificationLabelResolverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationLabelResolverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationLabelResolverHash();

  @$internal
  @override
  $ProviderElement<NotificationLabelResolver> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationLabelResolver create(Ref ref) {
    return notificationLabelResolver(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationLabelResolver value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationLabelResolver>(value),
    );
  }
}

String _$notificationLabelResolverHash() =>
    r'1d22b83a19fa93208b02f2512786bac304ada87f';

/// Platform seam for the time zone: override in tests.

@ProviderFor(timezoneBackend)
final timezoneBackendProvider = TimezoneBackendProvider._();

/// Platform seam for the time zone: override in tests.

final class TimezoneBackendProvider
    extends
        $FunctionalProvider<TimezoneBackend, TimezoneBackend, TimezoneBackend>
    with $Provider<TimezoneBackend> {
  /// Platform seam for the time zone: override in tests.
  TimezoneBackendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timezoneBackendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timezoneBackendHash();

  @$internal
  @override
  $ProviderElement<TimezoneBackend> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TimezoneBackend create(Ref ref) {
    return timezoneBackend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimezoneBackend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimezoneBackend>(value),
    );
  }
}

String _$timezoneBackendHash() => r'2810e1261a0074c81b74936fbfc69a393f04da7d';

/// Platform seam for local notifications: override in tests. The accent color
/// of Android notifications is the brand seed color (design tokens).

@ProviderFor(localNotificationBackend)
final localNotificationBackendProvider = LocalNotificationBackendProvider._();

/// Platform seam for local notifications: override in tests. The accent color
/// of Android notifications is the brand seed color (design tokens).

final class LocalNotificationBackendProvider
    extends
        $FunctionalProvider<
          LocalNotificationBackend,
          LocalNotificationBackend,
          LocalNotificationBackend
        >
    with $Provider<LocalNotificationBackend> {
  /// Platform seam for local notifications: override in tests. The accent color
  /// of Android notifications is the brand seed color (design tokens).
  LocalNotificationBackendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localNotificationBackendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localNotificationBackendHash();

  @$internal
  @override
  $ProviderElement<LocalNotificationBackend> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalNotificationBackend create(Ref ref) {
    return localNotificationBackend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalNotificationBackend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalNotificationBackend>(value),
    );
  }
}

String _$localNotificationBackendHash() =>
    r'333667686650258615e6858082b96c60d5f31b6a';

/// Platform seam for push: override in tests.

@ProviderFor(pushBackend)
final pushBackendProvider = PushBackendProvider._();

/// Platform seam for push: override in tests.

final class PushBackendProvider
    extends $FunctionalProvider<PushBackend, PushBackend, PushBackend>
    with $Provider<PushBackend> {
  /// Platform seam for push: override in tests.
  PushBackendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushBackendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushBackendHash();

  @$internal
  @override
  $ProviderElement<PushBackend> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PushBackend create(Ref ref) {
    return pushBackend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushBackend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushBackend>(value),
    );
  }
}

String _$pushBackendHash() => r'06cf5c607f543c3373b8aa324d72799bfa0d1a38';

/// Platform seam for the notification permission: override in tests.

@ProviderFor(notificationPermissionBackend)
final notificationPermissionBackendProvider =
    NotificationPermissionBackendProvider._();

/// Platform seam for the notification permission: override in tests.

final class NotificationPermissionBackendProvider
    extends
        $FunctionalProvider<
          NotificationPermissionBackend,
          NotificationPermissionBackend,
          NotificationPermissionBackend
        >
    with $Provider<NotificationPermissionBackend> {
  /// Platform seam for the notification permission: override in tests.
  NotificationPermissionBackendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPermissionBackendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPermissionBackendHash();

  @$internal
  @override
  $ProviderElement<NotificationPermissionBackend> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationPermissionBackend create(Ref ref) {
    return notificationPermissionBackend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationPermissionBackend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationPermissionBackend>(
        value,
      ),
    );
  }
}

String _$notificationPermissionBackendHash() =>
    r'849d5a4f563bf3b3a20e4610ccf9c393f73b5ae2';

/// The app wires the design-system rationale dialog here. Null means the flow
/// skips the explanation and goes straight to the system prompt.

@ProviderFor(notificationRationalePresenter)
final notificationRationalePresenterProvider =
    NotificationRationalePresenterProvider._();

/// The app wires the design-system rationale dialog here. Null means the flow
/// skips the explanation and goes straight to the system prompt.

final class NotificationRationalePresenterProvider
    extends
        $FunctionalProvider<
          NotificationRationalePresenter?,
          NotificationRationalePresenter?,
          NotificationRationalePresenter?
        >
    with $Provider<NotificationRationalePresenter?> {
  /// The app wires the design-system rationale dialog here. Null means the flow
  /// skips the explanation and goes straight to the system prompt.
  NotificationRationalePresenterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationRationalePresenterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationRationalePresenterHash();

  @$internal
  @override
  $ProviderElement<NotificationRationalePresenter?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationRationalePresenter? create(Ref ref) {
    return notificationRationalePresenter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationRationalePresenter? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationRationalePresenter?>(
        value,
      ),
    );
  }
}

String _$notificationRationalePresenterHash() =>
    r'56857b2e8c3a6a30cb0ad9bca936f252e622dbd0';

/// The permission flow (status, rationale, system prompt, settings).

@ProviderFor(notificationPermissionFlow)
final notificationPermissionFlowProvider =
    NotificationPermissionFlowProvider._();

/// The permission flow (status, rationale, system prompt, settings).

final class NotificationPermissionFlowProvider
    extends
        $FunctionalProvider<
          NotificationPermissionFlow,
          NotificationPermissionFlow,
          NotificationPermissionFlow
        >
    with $Provider<NotificationPermissionFlow> {
  /// The permission flow (status, rationale, system prompt, settings).
  NotificationPermissionFlowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPermissionFlowProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPermissionFlowHash();

  @$internal
  @override
  $ProviderElement<NotificationPermissionFlow> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationPermissionFlow create(Ref ref) {
    return notificationPermissionFlow(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationPermissionFlow value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationPermissionFlow>(value),
    );
  }
}

String _$notificationPermissionFlowHash() =>
    r'b7d93e6c4fb9196ecdc0bd04b72bcc632c69a057';

/// How the app tells its backend about push tokens. The default does nothing;
/// override it with a real registrar (see `DioPushTokenRegistrar`).

@ProviderFor(pushTokenRegistrar)
final pushTokenRegistrarProvider = PushTokenRegistrarProvider._();

/// How the app tells its backend about push tokens. The default does nothing;
/// override it with a real registrar (see `DioPushTokenRegistrar`).

final class PushTokenRegistrarProvider
    extends
        $FunctionalProvider<
          PushTokenRegistrar,
          PushTokenRegistrar,
          PushTokenRegistrar
        >
    with $Provider<PushTokenRegistrar> {
  /// How the app tells its backend about push tokens. The default does nothing;
  /// override it with a real registrar (see `DioPushTokenRegistrar`).
  PushTokenRegistrarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushTokenRegistrarProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushTokenRegistrarHash();

  @$internal
  @override
  $ProviderElement<PushTokenRegistrar> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PushTokenRegistrar create(Ref ref) {
    return pushTokenRegistrar(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushTokenRegistrar value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushTokenRegistrar>(value),
    );
  }
}

String _$pushTokenRegistrarHash() =>
    r'a985c41fb62614834c6590288b1dbfa1ceab0fee';

/// Opens a notification's `url` in the external browser.

@ProviderFor(notificationUrlOpener)
final notificationUrlOpenerProvider = NotificationUrlOpenerProvider._();

/// Opens a notification's `url` in the external browser.

final class NotificationUrlOpenerProvider
    extends
        $FunctionalProvider<
          NotificationUrlOpener,
          NotificationUrlOpener,
          NotificationUrlOpener
        >
    with $Provider<NotificationUrlOpener> {
  /// Opens a notification's `url` in the external browser.
  NotificationUrlOpenerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationUrlOpenerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationUrlOpenerHash();

  @$internal
  @override
  $ProviderElement<NotificationUrlOpener> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationUrlOpener create(Ref ref) {
    return notificationUrlOpener(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationUrlOpener value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationUrlOpener>(value),
    );
  }
}

String _$notificationUrlOpenerHash() =>
    r'39ec67fd505ca7c1b7787a7ad4025d065d8692ed';

/// Whether push works in this build: false when Firebase is not configured or
/// before the startup finished. The UI hides push-only settings when false.

@ProviderFor(PushAvailable)
final pushAvailableProvider = PushAvailableProvider._();

/// Whether push works in this build: false when Firebase is not configured or
/// before the startup finished. The UI hides push-only settings when false.
final class PushAvailableProvider
    extends $NotifierProvider<PushAvailable, bool> {
  /// Whether push works in this build: false when Firebase is not configured or
  /// before the startup finished. The UI hides push-only settings when false.
  PushAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushAvailableProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushAvailableHash();

  @$internal
  @override
  PushAvailable create() => PushAvailable();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$pushAvailableHash() => r'68f9d134c8fb60dce2bad880bc56be87acc80a63';

/// Whether push works in this build: false when Firebase is not configured or
/// before the startup finished. The UI hides push-only settings when false.

abstract class _$PushAvailable extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The OS permission to show notifications. `ref.invalidate` it after the user
/// returns from the system settings.

@ProviderFor(notificationPermissionState)
final notificationPermissionStateProvider =
    NotificationPermissionStateProvider._();

/// The OS permission to show notifications. `ref.invalidate` it after the user
/// returns from the system settings.

final class NotificationPermissionStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<NotificationPermissionState>,
          NotificationPermissionState,
          FutureOr<NotificationPermissionState>
        >
    with
        $FutureModifier<NotificationPermissionState>,
        $FutureProvider<NotificationPermissionState> {
  /// The OS permission to show notifications. `ref.invalidate` it after the user
  /// returns from the system settings.
  NotificationPermissionStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPermissionStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPermissionStateHash();

  @$internal
  @override
  $FutureProviderElement<NotificationPermissionState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NotificationPermissionState> create(Ref ref) {
    return notificationPermissionState(ref);
  }
}

String _$notificationPermissionStateHash() =>
    r'bb50d475f170726ccd3d7131267c49abf5a6acc3';

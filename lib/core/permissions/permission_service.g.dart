// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app wires the design-system dialog here (override in `app/`). Null
/// means no rationale UI.

@ProviderFor(permissionRationalePresenter)
final permissionRationalePresenterProvider =
    PermissionRationalePresenterProvider._();

/// The app wires the design-system dialog here (override in `app/`). Null
/// means no rationale UI.

final class PermissionRationalePresenterProvider
    extends
        $FunctionalProvider<
          PermissionRationalePresenter?,
          PermissionRationalePresenter?,
          PermissionRationalePresenter?
        >
    with $Provider<PermissionRationalePresenter?> {
  /// The app wires the design-system dialog here (override in `app/`). Null
  /// means no rationale UI.
  PermissionRationalePresenterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'permissionRationalePresenterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$permissionRationalePresenterHash();

  @$internal
  @override
  $ProviderElement<PermissionRationalePresenter?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PermissionRationalePresenter? create(Ref ref) {
    return permissionRationalePresenter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PermissionRationalePresenter? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PermissionRationalePresenter?>(
        value,
      ),
    );
  }
}

String _$permissionRationalePresenterHash() =>
    r'9a37ec6b857db4bf519530180d1dc1ac86808ca0';

/// Backend seam: override in tests with a fake.

@ProviderFor(permissionBackend)
final permissionBackendProvider = PermissionBackendProvider._();

/// Backend seam: override in tests with a fake.

final class PermissionBackendProvider
    extends
        $FunctionalProvider<
          PermissionBackend,
          PermissionBackend,
          PermissionBackend
        >
    with $Provider<PermissionBackend> {
  /// Backend seam: override in tests with a fake.
  PermissionBackendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'permissionBackendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$permissionBackendHash();

  @$internal
  @override
  $ProviderElement<PermissionBackend> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PermissionBackend create(Ref ref) {
    return permissionBackend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PermissionBackend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PermissionBackend>(value),
    );
  }
}

String _$permissionBackendHash() => r'f52dfc9b345cc796932c517e3448892bba3a6401';

/// The one [PermissionService] of the app.

@ProviderFor(permissionService)
final permissionServiceProvider = PermissionServiceProvider._();

/// The one [PermissionService] of the app.

final class PermissionServiceProvider
    extends
        $FunctionalProvider<
          PermissionService,
          PermissionService,
          PermissionService
        >
    with $Provider<PermissionService> {
  /// The one [PermissionService] of the app.
  PermissionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'permissionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$permissionServiceHash();

  @$internal
  @override
  $ProviderElement<PermissionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PermissionService create(Ref ref) {
    return permissionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PermissionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PermissionService>(value),
    );
  }
}

String _$permissionServiceHash() => r'bc1add47abfad5c310b93dfe980669d1a8481ff2';

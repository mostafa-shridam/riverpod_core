// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_info.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Platform seam: override in tests with a fake.

@ProviderFor(appInfoSource)
final appInfoSourceProvider = AppInfoSourceProvider._();

/// Platform seam: override in tests with a fake.

final class AppInfoSourceProvider
    extends $FunctionalProvider<AppInfoSource, AppInfoSource, AppInfoSource>
    with $Provider<AppInfoSource> {
  /// Platform seam: override in tests with a fake.
  AppInfoSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appInfoSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appInfoSourceHash();

  @$internal
  @override
  $ProviderElement<AppInfoSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppInfoSource create(Ref ref) {
    return appInfoSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppInfoSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppInfoSource>(value),
    );
  }
}

String _$appInfoSourceHash() => r'e472ff2d6ab3ebd9582f22076613ed3764c31f6a';

/// Name, version and build of the running app.

@ProviderFor(appInfo)
final appInfoProvider = AppInfoProvider._();

/// Name, version and build of the running app.

final class AppInfoProvider
    extends $FunctionalProvider<AsyncValue<AppInfo>, AppInfo, FutureOr<AppInfo>>
    with $FutureModifier<AppInfo>, $FutureProvider<AppInfo> {
  /// Name, version and build of the running app.
  AppInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appInfoHash();

  @$internal
  @override
  $FutureProviderElement<AppInfo> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AppInfo> create(Ref ref) {
    return appInfo(ref);
  }
}

String _$appInfoHash() => r'8e7e8c8ce5a2bcd55fb22caa7cfa872789ebd9e2';

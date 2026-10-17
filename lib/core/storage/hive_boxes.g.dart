// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_boxes.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The settings box. Overridden in bootstrap with the opened box.

@ProviderFor(settingsBox)
final settingsBoxProvider = SettingsBoxProvider._();

/// The settings box. Overridden in bootstrap with the opened box.

final class SettingsBoxProvider
    extends $FunctionalProvider<Box<dynamic>, Box<dynamic>, Box<dynamic>>
    with $Provider<Box<dynamic>> {
  /// The settings box. Overridden in bootstrap with the opened box.
  SettingsBoxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsBoxProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsBoxHash();

  @$internal
  @override
  $ProviderElement<Box<dynamic>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Box<dynamic> create(Ref ref) {
    return settingsBox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Box<dynamic> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Box<dynamic>>(value),
    );
  }
}

String _$settingsBoxHash() => r'5082ccfde58f13612e954878a74072d35b928d6d';

/// The cache box. Overridden in bootstrap with the opened box.

@ProviderFor(cacheBox)
final cacheBoxProvider = CacheBoxProvider._();

/// The cache box. Overridden in bootstrap with the opened box.

final class CacheBoxProvider
    extends
        $FunctionalProvider<
          Box<Map<dynamic, dynamic>>,
          Box<Map<dynamic, dynamic>>,
          Box<Map<dynamic, dynamic>>
        >
    with $Provider<Box<Map<dynamic, dynamic>>> {
  /// The cache box. Overridden in bootstrap with the opened box.
  CacheBoxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cacheBoxProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cacheBoxHash();

  @$internal
  @override
  $ProviderElement<Box<Map<dynamic, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Box<Map<dynamic, dynamic>> create(Ref ref) {
    return cacheBox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Box<Map<dynamic, dynamic>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Box<Map<dynamic, dynamic>>>(value),
    );
  }
}

String _$cacheBoxHash() => r'41fc031d172531ffc1bc6479e2a7c870d66392ac';

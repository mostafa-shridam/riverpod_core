// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crash_reporter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The crash reporter: Crashlytics when `AppConfig.enableCrashReporting` is on
/// AND Firebase is configured, otherwise Noop (D-042).

@ProviderFor(crashReporter)
final crashReporterProvider = CrashReporterProvider._();

/// The crash reporter: Crashlytics when `AppConfig.enableCrashReporting` is on
/// AND Firebase is configured, otherwise Noop (D-042).

final class CrashReporterProvider
    extends $FunctionalProvider<CrashReporter, CrashReporter, CrashReporter>
    with $Provider<CrashReporter> {
  /// The crash reporter: Crashlytics when `AppConfig.enableCrashReporting` is on
  /// AND Firebase is configured, otherwise Noop (D-042).
  CrashReporterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crashReporterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crashReporterHash();

  @$internal
  @override
  $ProviderElement<CrashReporter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CrashReporter create(Ref ref) {
    return crashReporter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrashReporter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrashReporter>(value),
    );
  }
}

String _$crashReporterHash() => r'e072be2d1e2b59ed2b165e11e3c7323cc82f026e';

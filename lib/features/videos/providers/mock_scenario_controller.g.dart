// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mock_scenario_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the "simulate" menu shows: never in prod, and only while the
/// mock source is active.

@ProviderFor(videosSimulationEnabled)
final videosSimulationEnabledProvider = VideosSimulationEnabledProvider._();

/// Whether the "simulate" menu shows: never in prod, and only while the
/// mock source is active.

final class VideosSimulationEnabledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the "simulate" menu shows: never in prod, and only while the
  /// mock source is active.
  VideosSimulationEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'videosSimulationEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$videosSimulationEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return videosSimulationEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$videosSimulationEnabledHash() =>
    r'999af7a5be0c51c3877359df0e62a85e688f0408';

/// The scenario the mock source answers with. Selecting one only switches the
/// source; the page reloads the list afterwards.

@ProviderFor(MockScenarioController)
final mockScenarioControllerProvider = MockScenarioControllerProvider._();

/// The scenario the mock source answers with. Selecting one only switches the
/// source; the page reloads the list afterwards.
final class MockScenarioControllerProvider
    extends $NotifierProvider<MockScenarioController, MockScenario> {
  /// The scenario the mock source answers with. Selecting one only switches the
  /// source; the page reloads the list afterwards.
  MockScenarioControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mockScenarioControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mockScenarioControllerHash();

  @$internal
  @override
  MockScenarioController create() => MockScenarioController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MockScenario value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MockScenario>(value),
    );
  }
}

String _$mockScenarioControllerHash() =>
    r'afcd1731791ab1eedf2113d10face1d716dbb894';

/// The scenario the mock source answers with. Selecting one only switches the
/// source; the page reloads the list afterwards.

abstract class _$MockScenarioController extends $Notifier<MockScenario> {
  MockScenario build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MockScenario, MockScenario>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MockScenario, MockScenario>,
              MockScenario,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

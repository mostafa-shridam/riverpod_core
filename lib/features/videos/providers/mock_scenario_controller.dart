import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/features/videos/data/sources/mock_scenario.dart';
import 'package:riverpod_core/features/videos/data/videos_repository.dart';

part 'mock_scenario_controller.g.dart';

/// Whether the "simulate" menu shows: never in prod, and only while the
/// mock source is active.
@riverpod
bool videosSimulationEnabled(Ref ref) {
  final flavor = ref.watch(appConfigProvider).flavor;
  return flavor != Flavor.prod &&
      ref.watch(videosRepositoryProvider).supportsSimulation;
}

/// The scenario the mock source answers with. Selecting one only switches the
/// source; the page reloads the list afterwards.
@riverpod
class MockScenarioController extends _$MockScenarioController {
  @override
  MockScenario build() => ref.watch(videosRepositoryProvider).scenario;

  void select(MockScenario scenario) {
    ref.read(videosRepositoryProvider).simulate(scenario);
    state = scenario;
  }
}

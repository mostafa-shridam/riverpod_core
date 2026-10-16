import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/design_system/widgets/bottom_sheets/app_selection_sheet.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_icon_button.dart';
import 'package:riverpod_core/features/videos/data/sources/mock_scenario.dart';
import 'package:riverpod_core/features/videos/providers/mock_scenario_controller.dart';
import 'package:riverpod_core/features/videos/providers/videos_controller.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// App bar action that picks the mock scenario, so every data state of the
/// list can be shown. The page only builds it when the simulation is enabled
/// (never in prod).
class SimulateMenuButton extends ConsumerWidget {
  const SimulateMenuButton({super.key});

  static String _label(MockScenario scenario) => switch (scenario) {
    MockScenario.success => LocaleKeys.videos_simulate_success.tr(),
    MockScenario.empty => LocaleKeys.videos_simulate_empty.tr(),
    MockScenario.error => LocaleKeys.videos_simulate_error.tr(),
    MockScenario.offline => LocaleKeys.videos_simulate_offline.tr(),
    MockScenario.slow => LocaleKeys.videos_simulate_slow.tr(),
    MockScenario.partial => LocaleKeys.videos_simulate_partial.tr(),
  };

  static IconData _icon(MockScenario scenario) => switch (scenario) {
    MockScenario.success => Icons.check_circle_outline_rounded,
    MockScenario.empty => Icons.inbox_outlined,
    MockScenario.error => Icons.error_outline_rounded,
    MockScenario.offline => Icons.wifi_off_rounded,
    MockScenario.slow => Icons.hourglass_bottom_rounded,
    MockScenario.partial => Icons.warning_amber_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppIconButton(
      icon: Icons.tune_rounded,
      tooltip: LocaleKeys.videos_simulate_tooltip.tr(),
      onPressed: () async {
        final current = ref.read(mockScenarioControllerProvider);
        final picked = await AppSelectionSheet.show<MockScenario>(
          context: context,
          title: LocaleKeys.videos_simulate_title.tr(),
          selected: [current],
          options: [
            for (final scenario in MockScenario.values)
              AppSelectionOption(
                value: scenario,
                label: _label(scenario),
                icon: _icon(scenario),
              ),
          ],
        );
        if (picked == null || picked.isEmpty) return;
        ref.read(mockScenarioControllerProvider.notifier).select(picked.first);
        // Reload from scratch so loading and slow states are visible too.
        await ref.read(videosControllerProvider.notifier).reload();
      },
    );
  }
}

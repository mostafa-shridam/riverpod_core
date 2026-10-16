import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_core/core/connectivity/connectivity_provider.dart';
import 'package:riverpod_core/core/connectivity/connectivity_service.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/async/async_value_view.dart';
import 'package:riverpod_core/core/design_system/widgets/async/empty_state.dart';
import 'package:riverpod_core/core/design_system/widgets/async/error_state.dart';
import 'package:riverpod_core/core/design_system/widgets/async/offline_banner.dart';
import 'package:riverpod_core/core/design_system/widgets/async/skeleton.dart';
import 'package:riverpod_core/core/design_system/widgets/async/skeleton_block.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_card.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_list_tile.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/progress/app_progress_bar.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/progress/app_progress_indicator.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_chip_group.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/showcase_group.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/showcase_section.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// The eight data states of `AsyncValueView`.
enum ShowcaseDataState {
  loading,
  empty,
  error,
  offline,
  stale,
  partial,
  refreshing,
  success,
}

/// Data states (switchable `AsyncValueView` demo), skeleton, empty and error
/// states, offline banners and progress indicators.
class StatesSection extends StatefulWidget {
  const StatesSection({super.key});

  @override
  State<StatesSection> createState() => _StatesSectionState();
}

class _StatesSectionState extends State<StatesSection> {
  static const _items = ['A', 'B', 'C'];
  static final _stamp = DateTime(2026, 3, 14, 9, 30);

  ShowcaseDataState _state = ShowcaseDataState.success;

  String _label(ShowcaseDataState state) => switch (state) {
    ShowcaseDataState.loading => LocaleKeys.showcase_states_loading.tr(),
    ShowcaseDataState.empty => LocaleKeys.showcase_states_empty.tr(),
    ShowcaseDataState.error => LocaleKeys.showcase_states_error.tr(),
    ShowcaseDataState.offline => LocaleKeys.showcase_states_offline.tr(),
    ShowcaseDataState.stale => LocaleKeys.showcase_states_stale.tr(),
    ShowcaseDataState.partial => LocaleKeys.showcase_states_partial.tr(),
    ShowcaseDataState.refreshing => LocaleKeys.showcase_states_refreshing.tr(),
    ShowcaseDataState.success => LocaleKeys.showcase_states_success.tr(),
  };

  AsyncValue<List<String>> get _value => switch (_state) {
    ShowcaseDataState.loading => const AsyncLoading(),
    ShowcaseDataState.empty => const AsyncData(<String>[]),
    ShowcaseDataState.error => const AsyncError(
      ServerException(statusCode: 500),
      StackTrace.empty,
    ),
    ShowcaseDataState.offline => const AsyncError(
      NetworkException(),
      StackTrace.empty,
    ),
    // ignore: invalid_use_of_internal_member
    ShowcaseDataState.refreshing =>
      const AsyncLoading<List<String>>()
      // ignore: invalid_use_of_internal_member
      .copyWithPrevious(const AsyncData(_items)),
    _ => const AsyncData(_items),
  };

  void _reset() => setState(() => _state = ShowcaseDataState.success);

  Widget _demo() {
    final offline = _state == ShowcaseDataState.offline;
    final height = context.tokens.spacing.xxxl * 7;
    return SizedBox(
      height: height,
      // The connectivity stream is replaced only inside this demo, so the
      // "offline" state does not depend on the device's real connection.
      child: ProviderScope(
        key: ValueKey(offline),
        overrides: [
          connectivityProvider.overrideWith(
            (ref) => Stream.value(
              offline ? ConnectivityStatus.offline : ConnectivityStatus.online,
            ),
          ),
        ],
        child: AsyncValueView<List<String>>(
          value: _value,
          isEmpty: _state == ShowcaseDataState.empty,
          isStale: _state == ShowcaseDataState.stale,
          hasPartialError: _state == ShowcaseDataState.partial,
          lastUpdated: _state == ShowcaseDataState.stale ? _stamp : null,
          onRetry: _reset,
          builder: (context, data) => ListView(
            children: [
              for (final item in data)
                AppListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: Text(LocaleKeys.showcase_states_item.tr(args: [item])),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.tokens.spacing;
    return ShowcaseSection(
      sectionKey: const ValueKey('showcase-states'),
      title: LocaleKeys.showcase_sections_states.tr(),
      children: [
        AppChipGroup<ShowcaseDataState>(
          label: LocaleKeys.showcase_states_pick.tr(),
          selected: [_state],
          allowDeselect: false,
          onChanged: (v) => setState(() => _state = v.first),
          options: [
            for (final s in ShowcaseDataState.values)
              AppChipOption(value: s, label: _label(s)),
          ],
        ),
        AppCard(
          variant: AppCardVariant.outlined,
          padding: EdgeInsetsDirectional.zero,
          child: _demo(),
        ),
        ShowcaseGroup(
          label: LocaleKeys.showcase_states_skeleton.tr(),
          children: [
            Skeleton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkeletonBlock.circle(size: spacing.xxxl),
                  SizedBox(width: spacing.md),
                  SkeletonBlock(width: spacing.xxxl * 3, height: spacing.lg),
                ],
              ),
            ),
          ],
        ),
        AppCard(
          variant: AppCardVariant.outlined,
          child: EmptyState(
            title: LocaleKeys.showcase_states_emptyTitle.tr(),
            message: LocaleKeys.showcase_states_emptyMessage.tr(),
            actionLabel: LocaleKeys.showcase_states_emptyAction.tr(),
            onAction: () {},
          ),
        ),
        AppCard(
          variant: AppCardVariant.outlined,
          child: ErrorState(
            exception: const ServerException(statusCode: 500),
            onRetry: () {},
          ),
        ),
        AppCard(
          variant: AppCardVariant.outlined,
          child: ErrorState(
            exception: const NetworkException(),
            isOffline: true,
            onRetry: () {},
          ),
        ),
        const OfflineBanner(isOffline: true),
        OfflineBanner(isOffline: false, isStale: true, lastUpdated: _stamp),
        const AppProgressBar(),
        AppProgressBar(
          value: 0.6,
          label: LocaleKeys.showcase_states_progress.tr(),
          showPercent: true,
        ),
        ShowcaseGroup(
          label: LocaleKeys.showcase_states_spinners.tr(),
          children: [
            for (final size in AppProgressSize.values)
              AppProgressIndicator(size: size),
            const AppProgressIndicator(value: 0.7),
          ],
        ),
      ],
    );
  }
}

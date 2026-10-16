import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/connectivity/connectivity_provider.dart';
import 'package:riverpod_core/core/connectivity/connectivity_service.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/async/async_value_view.dart';
import 'package:riverpod_core/core/design_system/widgets/async/empty_state.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/snackbar/app_snackbar.dart';
import 'package:riverpod_core/core/design_system/widgets/inputs/app_search_field.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_app_bar.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_scaffold.dart';
import 'package:riverpod_core/core/router/routes.dart';
import 'package:riverpod_core/features/videos/data/sources/mock_scenario.dart';
import 'package:riverpod_core/features/videos/presentation/widgets/custom_url_button.dart';
import 'package:riverpod_core/features/videos/presentation/widgets/simulate_menu_button.dart';
import 'package:riverpod_core/features/videos/presentation/widgets/video_card.dart';
import 'package:riverpod_core/features/videos/presentation/widgets/video_list_skeleton.dart';
import 'package:riverpod_core/features/videos/providers/favorite_videos_controller.dart';
import 'package:riverpod_core/features/videos/providers/mock_scenario_controller.dart';
import 'package:riverpod_core/features/videos/providers/videos_controller.dart';
import 'package:riverpod_core/features/videos/providers/videos_state.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Reference list page (`/videos`, dev and staging only): search, pull to
/// refresh, favorites, and the "simulate" menu that shows all data states.
class VideosPage extends ConsumerWidget {
  static const routeName = '/videos';

  const VideosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listed = ref.watch(videosControllerProvider);
    final controller = ref.read(videosControllerProvider.notifier);
    // After a "from scratch" reload the old data must not show through.
    final dropOld = controller.dropsPreviousData && listed.hasValue;
    final videos = !dropOld
        ? listed
        : listed.isLoading
        ? const AsyncLoading<VideosState>()
        : listed.hasError
        ? AsyncError<VideosState>(listed.error!, listed.stackTrace!)
        : listed;
    final favorites = ref.watch(favoriteVideosControllerProvider).value ?? {};
    final simulation = ref.watch(videosSimulationEnabledProvider);
    final scenario = ref.watch(mockScenarioControllerProvider);
    final data = videos.value;
    final spacing = context.tokens.spacing;

    final view = AsyncValueView<VideosState>(
      value: videos,
      isEmpty: data != null && data.visible.isEmpty,
      hasPartialError: data?.hasPartialError ?? false,
      partialErrorMessage: LocaleKeys.videos_partialError.tr(),
      lastUpdated: data?.loadedAt,
      onRetry: controller.refresh,
      onRefresh: controller.refresh,
      loading: const VideoListSkeleton(),
      empty: _empty(data),
      builder: (context, state) => ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.symmetric(vertical: spacing.sm),
        itemCount: state.visible.length,
        separatorBuilder: (_, _) => SizedBox(height: spacing.md),
        itemBuilder: (context, index) {
          final video = state.visible[index];
          return VideoCard(
            video: video,
            isFavorite: favorites.contains(video.id),
            onTap: () => VideoDetailRoute(id: video.id).push<void>(context),
            onToggleFavorite: () => _toggleFavorite(
              context,
              ref,
              id: video.id,
              wasFavorite: favorites.contains(video.id),
            ),
          );
        },
      ),
    );

    return AppScaffold(
      appBar: AppAppBar(
        title: LocaleKeys.videos_title.tr(),
        actions: [
          const CustomUrlButton(),
          if (simulation) const SimulateMenuButton(),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.symmetric(vertical: spacing.sm),
            child: AppSearchField(
              hint: LocaleKeys.videos_searchHint.tr(),
              onChanged: controller.search,
            ),
          ),
          Expanded(
            // "Offline" simulation: the view reads connectivity, so the
            // simulated scenario overrides it for this subtree only.
            child: simulation && scenario == MockScenario.offline
                ? ProviderScope(
                    overrides: [
                      connectivityProvider.overrideWith(
                        (ref) => Stream.value(ConnectivityStatus.offline),
                      ),
                    ],
                    child: view,
                  )
                : view,
          ),
        ],
      ),
    );
  }

  Widget _empty(VideosState? data) {
    final searching = data != null && data.query.isNotEmpty;
    return EmptyState(
      icon: searching ? Icons.search_off_rounded : Icons.video_library_outlined,
      title: searching
          ? LocaleKeys.videos_noResultsTitle.tr()
          : LocaleKeys.videos_emptyTitle.tr(),
      message: searching
          ? LocaleKeys.videos_noResultsMessage.tr()
          : LocaleKeys.videos_emptyMessage.tr(),
    );
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref, {
    required String id,
    required bool wasFavorite,
  }) async {
    await ref.read(favoriteVideosControllerProvider.notifier).toggle(id);
    if (!context.mounted) return;
    showAppSnackbar(
      context,
      message: wasFavorite
          ? LocaleKeys.videos_favorite_removed.tr()
          : LocaleKeys.videos_favorite_added.tr(),
      replaceCurrent: true,
    );
  }
}

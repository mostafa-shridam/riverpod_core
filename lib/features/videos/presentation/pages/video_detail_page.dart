import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/async/async_value_view.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/snackbar/app_snackbar.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_app_bar.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_scaffold.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_backend.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_player.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_source.dart';
import 'package:riverpod_core/features/videos/data/models/video.dart';
import 'package:riverpod_core/features/videos/data/videos_repository.dart';
import 'package:riverpod_core/features/videos/presentation/pages/videos_page.dart';
import 'package:riverpod_core/features/videos/presentation/widgets/related_videos_section.dart';
import 'package:riverpod_core/features/videos/presentation/widgets/video_detail_skeleton.dart';
import 'package:riverpod_core/features/videos/presentation/widgets/video_thumbnail.dart';
import 'package:riverpod_core/features/videos/providers/favorite_videos_controller.dart';
import 'package:riverpod_core/features/videos/providers/video_detail_providers.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Player page (`/videos/:id`): the video, its description, a favorite toggle
/// and related videos. With [customUrl] it plays that link instead of a
/// catalogue video (id [customVideoId]).
class VideoDetailPage extends ConsumerWidget {
  /// Path pattern; the typed route fills `:id`.
  static const routeName = '${VideosPage.routeName}/:id';

  const VideoDetailPage({
    super.key,
    required this.id,
    this.customUrl,
    this.backendFactory = createVideoPlayerBackend,
  });

  final String id;
  final String? customUrl;

  /// Playback engine factory; tests pass a fake.
  final AppVideoBackendFactory backendFactory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final video = ref.watch(videoDetailProvider(id, customUrl: customUrl));
    return AppScaffold(
      appBar: AppAppBar(title: LocaleKeys.videos_detail_title.tr()),
      body: AsyncValueView<Video>(
        value: video,
        loading: const VideoDetailSkeleton(),
        onRetry: () =>
            ref.invalidate(videoDetailProvider(id, customUrl: customUrl)),
        builder: (context, data) => _Content(
          video: data,
          isCustom: customUrl != null,
          backendFactory: backendFactory,
        ),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({
    required this.video,
    required this.isCustom,
    required this.backendFactory,
  });

  final Video video;
  final bool isCustom;
  final AppVideoBackendFactory backendFactory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = context.tokens.spacing;
    final theme = Theme.of(context);
    final isFavorite =
        ref.watch(favoriteVideosControllerProvider).value?.contains(video.id) ??
        false;

    return ListView(
      padding: EdgeInsetsDirectional.symmetric(vertical: spacing.sm),
      children: [
        AppVideoPlayer(
          // Keyed by URL: another video gets a fresh player.
          key: ValueKey(video.url),
          source: AppVideoSource.network(video.url),
          autoPlay: true,
          backendFactory: backendFactory,
          placeholder: VideoThumbnail(video: video, radius: BorderRadius.zero),
        ),
        SizedBox(height: spacing.lg),
        Text(
          isCustom ? LocaleKeys.videos_detail_customTitle.tr() : video.title,
          style: theme.textTheme.headlineSmall,
        ),
        SizedBox(height: spacing.sm),
        Text(
          isCustom
              ? LocaleKeys.videos_detail_customDescription.tr()
              : video.description,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (isCustom) ...[
          SizedBox(height: spacing.sm),
          SelectableText(video.url, style: theme.textTheme.bodySmall),
        ],
        // A custom link is not part of the catalogue: nothing to favorite.
        if (!isCustom) ...[
          SizedBox(height: spacing.lg),
          AppButton(
            label: isFavorite
                ? LocaleKeys.videos_favorite_remove.tr()
                : LocaleKeys.videos_favorite_add.tr(),
            icon: isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            variant: AppButtonVariant.tonal,
            onPressed: () => _toggle(context, ref, wasFavorite: isFavorite),
          ),
          RelatedVideosSection(videoId: video.id),
        ],
      ],
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref, {
    required bool wasFavorite,
  }) async {
    await ref.read(favoriteVideosControllerProvider.notifier).toggle(video.id);
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

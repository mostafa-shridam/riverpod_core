import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_list_tile.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_section_header.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/app_status_type.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/banner/app_banner.dart';
import 'package:riverpod_core/core/router/routes.dart';
import 'package:riverpod_core/core/utils/formatting/app_formatters.dart';
import 'package:riverpod_core/features/videos/presentation/widgets/video_thumbnail.dart';
import 'package:riverpod_core/features/videos/providers/video_detail_providers.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// "Related videos" of the detail page. Loads on its own: while loading it is
/// hidden, and a failure shows an inline error row with retry while the rest
/// of the page stays usable (the `partial` state).
class RelatedVideosSection extends ConsumerWidget {
  const RelatedVideosSection({super.key, required this.videoId});

  final String videoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final related = ref.watch(relatedVideosProvider(videoId));
    final spacing = context.tokens.spacing;
    return related.when(
      loading: () => const SizedBox.shrink(),
      error: (error, _) => Padding(
        padding: EdgeInsetsDirectional.only(top: spacing.lg),
        child: AppBanner(
          type: AppStatusType.error,
          message: LocaleKeys.videos_detail_relatedError.tr(),
          actionLabel: LocaleKeys.ds_lists_retry.tr(),
          onAction: () => ref.invalidate(relatedVideosProvider(videoId)),
        ),
      ),
      data: (videos) {
        if (videos.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSectionHeader(
              title: LocaleKeys.videos_detail_related.tr(),
              padding: EdgeInsetsDirectional.only(
                top: spacing.xl,
                bottom: spacing.xs,
              ),
            ),
            for (final video in videos)
              AppListTile(
                title: Text(video.title, maxLines: 1),
                subtitle: Text(
                  formatVideoDuration(context.formatters, video.duration),
                ),
                leading: const Icon(Icons.play_circle_outline_rounded),
                showChevron: true,
                onTap: () => VideoDetailRoute(id: video.id).push<void>(context),
              ),
          ],
        );
      },
    );
  }
}

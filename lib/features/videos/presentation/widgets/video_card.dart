import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_icon_button.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_card.dart';
import 'package:riverpod_core/features/videos/data/models/video.dart';
import 'package:riverpod_core/features/videos/presentation/widgets/video_thumbnail.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// List item: thumbnail with duration badge, title, short description and the
/// favorite toggle.
class VideoCard extends StatelessWidget {
  const VideoCard({
    super.key,
    required this.video,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final Video video;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      semanticLabel: video.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(tokens.spacing.sm),
            child: VideoThumbnail(video: video),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: tokens.spacing.lg,
              end: tokens.spacing.xs,
              bottom: tokens.spacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                      SizedBox(height: tokens.spacing.xs),
                      Text(
                        video.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AppIconButton(
                  icon: isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  tooltip: isFavorite
                      ? LocaleKeys.videos_favorite_remove.tr()
                      : LocaleKeys.videos_favorite_add.tr(),
                  onPressed: onToggleFavorite,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

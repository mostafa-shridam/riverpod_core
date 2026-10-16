import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/async/skeleton.dart';
import 'package:riverpod_core/features/videos/data/models/video.dart';
import 'package:riverpod_core/features/videos/presentation/widgets/video_card.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

const _placeholder = Video(
  id: 'placeholder',
  title: 'Placeholder video title',
  description: 'Placeholder description that fills two lines of the card.',
  url: '',
  durationSeconds: 0,
);

/// Loading placeholder: the real card layout with fake data, as DESIGN_SYSTEM
/// asks ("skeleton matching final layout").
class VideoListSkeleton extends StatelessWidget {
  const VideoListSkeleton({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final spacing = context.tokens.spacing;
    return Semantics(
      label: LocaleKeys.videos_title.tr(),
      container: true,
      liveRegion: true,
      child: ExcludeSemantics(
        child: Skeleton(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsetsDirectional.symmetric(vertical: spacing.sm),
            itemCount: itemCount,
            separatorBuilder: (_, _) => SizedBox(height: spacing.md),
            itemBuilder: (_, _) => VideoCard(
              video: _placeholder,
              isFavorite: false,
              onTap: () {},
              onToggleFavorite: () {},
            ),
          ),
        ),
      ),
    );
  }
}

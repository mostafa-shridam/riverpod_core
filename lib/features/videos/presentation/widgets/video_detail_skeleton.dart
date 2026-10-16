import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/async/skeleton.dart';
import 'package:riverpod_core/core/design_system/widgets/async/skeleton_block.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Loading placeholder of the detail page: player box, title, two text lines.
class VideoDetailSkeleton extends StatelessWidget {
  const VideoDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final line = tokens.sizes.iconSm;
    return Semantics(
      label: LocaleKeys.videos_detail_title.tr(),
      container: true,
      liveRegion: true,
      child: ExcludeSemantics(
        child: Skeleton(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsetsDirectional.symmetric(vertical: spacing.sm),
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: SkeletonBlock(radius: tokens.radius.lg),
              ),
              SizedBox(height: spacing.lg),
              SkeletonBlock(height: line * 1.5),
              SizedBox(height: spacing.md),
              SkeletonBlock(height: line),
              SizedBox(height: spacing.sm),
              SkeletonBlock(height: line),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/async/async_strings.dart';
import 'package:riverpod_core/core/design_system/widgets/async/skeleton.dart';
import 'package:riverpod_core/core/design_system/widgets/async/skeleton_block.dart';

/// Default loading placeholder: [itemCount] rows with a leading circle and
/// two text lines. Pages with a different layout pass their own skeleton.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.itemCount = 8, this.semanticLabel});

  final int itemCount;

  /// Overrides the localized "loading" announcement.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final avatar = tokens.sizes.minTouchTarget;
    final line = tokens.sizes.iconSm;
    return Semantics(
      label: semanticLabel ?? asyncLoadingKey.tr(),
      container: true,
      liveRegion: true,
      child: ExcludeSemantics(
        child: Skeleton(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsetsDirectional.all(spacing.lg),
            itemCount: itemCount,
            separatorBuilder: (_, _) => SizedBox(height: spacing.lg),
            itemBuilder: (_, _) => Row(
              children: [
                SkeletonBlock.circle(size: avatar),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SkeletonBlock(height: line),
                      SizedBox(height: spacing.sm),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: FractionallySizedBox(
                          widthFactor: 0.6,
                          child: SkeletonBlock(height: line),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

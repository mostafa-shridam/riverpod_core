import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/async/async_motion.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Turns [child] into a shimmering placeholder of its own layout (wraps the
/// `skeletonizer` package; features never import it). Build the real layout
/// with fake data and wrap it, so the skeleton matches the final screen.
/// Use `SkeletonBlock` for shapes that have no widget of their own.
class Skeleton extends StatelessWidget {
  const Skeleton({super.key, required this.child, this.enabled = true});

  final Widget child;

  /// When false the real [child] is shown without any effect.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHigh;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final highlight = dark
        ? scheme.surfaceContainerHighest
        : scheme.surfaceContainerLowest;
    final animate = !MediaQuery.disableAnimationsOf(context);
    return Skeletonizer(
      enabled: enabled,
      effect: animate
          ? ShimmerEffect(
              baseColor: base,
              highlightColor: highlight,
              // Slow sweep: four times the slowest motion token.
              duration: motionDuration(context, tokens.durations.slow * 4),
            )
          : SolidColorEffect(color: base),
      containersColor: scheme.surfaceContainer,
      textBoneBorderRadius: TextBoneBorderRadius(
        BorderRadius.circular(tokens.radius.sm),
      ),
      child: child,
    );
  }
}

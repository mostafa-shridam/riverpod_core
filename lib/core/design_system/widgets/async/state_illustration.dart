import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';

/// Icon artwork for empty/error/offline states, built only from icons,
/// circles and tokens: a soft halo, a tinted disc, the icon, and two small
/// accent dots. Decorative, so hidden from accessibility.
class StateIllustration extends StatelessWidget {
  const StateIllustration({
    super.key,
    required this.icon,
    required this.accent,
    required this.container,
    required this.onContainer,
  });

  final IconData icon;

  /// Color of the decorative dots.
  final Color accent;

  /// Fill of the inner disc.
  final Color container;

  /// Icon color on [container].
  final Color onContainer;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final halo = spacing.xxxl * 3;
    final disc = spacing.xxxl * 2;
    final dot = spacing.md;
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: halo,
        child: Stack(
          alignment: Alignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.surfaceContainerHigh,
              ),
              child: SizedBox.square(dimension: halo),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: container,
              ),
              child: SizedBox.square(
                dimension: disc,
                child: Icon(
                  icon,
                  size: tokens.sizes.iconLg * 2,
                  color: onContainer,
                ),
              ),
            ),
            PositionedDirectional(
              top: spacing.lg,
              end: spacing.xl,
              child: _Dot(size: dot, color: accent),
            ),
            PositionedDirectional(
              bottom: spacing.xl,
              start: spacing.lg,
              child: _Dot(size: spacing.sm, color: scheme.tertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: SizedBox.square(dimension: size),
  );
}

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Page indicator: one dot per slide, the current one wider. It is a [Row],
/// so it mirrors with the text direction.
class OnboardingDots extends StatelessWidget {
  const OnboardingDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: LocaleKeys.onboarding_pageOf.tr(args: ['${index + 1}', '$count']),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: tokens.durations.normal,
              curve: tokens.durations.standardCurve,
              margin: EdgeInsets.symmetric(horizontal: tokens.spacing.xxs),
              width: i == index ? tokens.spacing.xl : tokens.spacing.sm,
              height: tokens.spacing.sm,
              decoration: BoxDecoration(
                color: i == index ? scheme.primary : scheme.outlineVariant,
                borderRadius: BorderRadius.circular(tokens.radius.full),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/features/onboarding/data/onboarding_slides.dart';

/// One slide: an icon in a tinted circle, then the localized title and body.
class OnboardingSlideView extends StatelessWidget {
  const OnboardingSlideView({super.key, required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final illustration = tokens.spacing.xxxl * 3;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.spacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ExcludeSemantics(
            child: Container(
              width: illustration,
              height: illustration,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                slide.icon,
                size: illustration / 2,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          SizedBox(height: tokens.spacing.xl),
          Text(
            slide.titleKey.tr(),
            style: text.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.spacing.md),
          Text(
            slide.bodyKey.tr(),
            style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

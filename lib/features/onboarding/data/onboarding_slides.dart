import 'package:flutter/material.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// One onboarding slide: an icon illustration and two localization keys.
class OnboardingSlide {
  const OnboardingSlide({
    required this.icon,
    required this.titleKey,
    required this.bodyKey,
  });

  final IconData icon;
  final String titleKey;
  final String bodyKey;
}

/// The slides, in order. Illustrations are icons, so no image assets ship.
const onboardingSlides = [
  OnboardingSlide(
    icon: Icons.waving_hand_rounded,
    titleKey: LocaleKeys.onboarding_slides_welcome_title,
    bodyKey: LocaleKeys.onboarding_slides_welcome_body,
  ),
  OnboardingSlide(
    icon: Icons.insights_rounded,
    titleKey: LocaleKeys.onboarding_slides_progress_title,
    bodyKey: LocaleKeys.onboarding_slides_progress_body,
  ),
  OnboardingSlide(
    icon: Icons.verified_user_rounded,
    titleKey: LocaleKeys.onboarding_slides_secure_title,
    bodyKey: LocaleKeys.onboarding_slides_secure_body,
  ),
];

import 'package:flutter/material.dart';

import 'package:riverpod_core/design_system/tokens/app_colors.dart';
import 'package:riverpod_core/design_system/tokens/app_durations.dart';
import 'package:riverpod_core/design_system/tokens/app_elevation.dart';
import 'package:riverpod_core/design_system/tokens/app_radius.dart';
import 'package:riverpod_core/design_system/tokens/app_spacing.dart';

/// Non-M3 design tokens, read in widgets via `context.tokens`.
/// Built into the theme by `buildLightTheme()` / `buildDarkTheme()`.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    this.spacing = AppSpacing.standard,
    this.radius = AppRadius.standard,
    this.elevation = AppElevation.standard,
    this.durations = AppDurations.standard,
    this.colors = AppSemanticColors.light,
  });

  static const AppTokens light = AppTokens();

  static const AppTokens dark = AppTokens(colors: AppSemanticColors.dark);

  final AppSpacing spacing;
  final AppRadius radius;
  final AppElevation elevation;
  final AppDurations durations;
  final AppSemanticColors colors;

  @override
  AppTokens copyWith({
    AppSpacing? spacing,
    AppRadius? radius,
    AppElevation? elevation,
    AppDurations? durations,
    AppSemanticColors? colors,
  }) {
    return AppTokens(
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      elevation: elevation ?? this.elevation,
      durations: durations ?? this.durations,
      colors: colors ?? this.colors,
    );
  }

  /// Scales are not interpolated; the switch happens at the midpoint.
  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return t < 0.5 ? this : other;
  }
}

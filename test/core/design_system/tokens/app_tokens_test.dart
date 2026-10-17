import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/tokens/app_colors.dart';
import 'package:riverpod_core/core/design_system/tokens/app_sizes.dart';
import 'package:riverpod_core/core/design_system/tokens/app_tokens.dart';

void main() {
  test('light and dark token sets use their own semantic colors', () {
    expect(AppTokens.light.colors, AppSemanticColors.light);
    expect(AppTokens.dark.colors, AppSemanticColors.dark);
    expect(
      AppTokens.light.colors.success,
      isNot(AppTokens.dark.colors.success),
    );
  });

  test('spacing follows the 4-pt scale from DESIGN_SYSTEM.md', () {
    const spacing = AppTokens.light;
    expect(spacing.spacing.xxs, 2);
    expect(spacing.spacing.xs, 4);
    expect(spacing.spacing.sm, 8);
    expect(spacing.spacing.md, 12);
    expect(spacing.spacing.lg, 16);
    expect(spacing.spacing.xl, 24);
    expect(spacing.spacing.xxl, 32);
    expect(spacing.spacing.xxxl, 48);
  });

  test('radius, elevation and durations match DESIGN_SYSTEM.md', () {
    const tokens = AppTokens.light;
    expect(tokens.radius.sm, 8);
    expect(tokens.radius.full, 999);
    expect(tokens.elevation.none, 0);
    expect(tokens.elevation.high, 6);
    expect(tokens.durations.normal, const Duration(milliseconds: 250));
    expect(tokens.durations.slow, const Duration(milliseconds: 400));
  });

  test('copyWith replaces only the given group', () {
    final copy = AppTokens.light.copyWith(colors: AppSemanticColors.dark);
    expect(copy.colors, AppSemanticColors.dark);
    expect(copy.spacing, AppTokens.light.spacing);
  });

  test('lerp returns the other set past the midpoint', () {
    expect(AppTokens.light.lerp(AppTokens.dark, 0.2), AppTokens.light);
    expect(AppTokens.light.lerp(AppTokens.dark, 0.8), AppTokens.dark);
    expect(AppTokens.light.lerp(null, 0.8), AppTokens.light);
  });

  test('component sizes and search debounce match the D-025 spec', () {
    const tokens = AppTokens.light;
    expect(tokens.sizes.minTouchTarget, 48);
    expect(tokens.sizes.buttonHeightSm, 40);
    expect(tokens.sizes.buttonHeightMd, 48);
    expect(tokens.sizes.buttonHeightLg, 56);
    expect(tokens.sizes.otpBoxWidth, 48);
    expect(tokens.durations.searchDebounce, const Duration(milliseconds: 300));
    expect(
      AppTokens.light.copyWith(sizes: const AppSizes(iconMd: 30)).sizes.iconMd,
      30,
    );
  });
}

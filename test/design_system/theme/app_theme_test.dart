import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/design_system/theme/app_theme.dart';
import 'package:riverpod_core/design_system/tokens/app_tokens.dart';

/// WCAG 2.x contrast ratio between two opaque colors.
double _contrast(Color a, Color b) {
  double luminance(Color c) {
    double channel(double v) => v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(c.r) +
        0.7152 * channel(c.g) +
        0.0722 * channel(c.b);
  }

  final la = luminance(a);
  final lb = luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  final themes = <String, ThemeData Function()>{
    'light': buildLightTheme,
    'dark': buildDarkTheme,
  };

  for (final entry in themes.entries) {
    group('${entry.key} theme', () {
      late ThemeData theme;
      late ColorScheme scheme;
      late AppTokens tokens;

      setUp(() {
        theme = entry.value();
        scheme = theme.colorScheme;
        tokens = theme.extension<AppTokens>()!;
      });

      test('is Material 3 with the requested brightness', () {
        expect(theme.useMaterial3, isTrue);
        expect(
          scheme.brightness,
          entry.key == 'dark' ? Brightness.dark : Brightness.light,
        );
      });

      test('M3 text pairs reach WCAG AA 4.5:1', () {
        final pairs = <String, (Color, Color)>{
          'onSurface/surface': (scheme.onSurface, scheme.surface),
          'onSurfaceVariant/surface': (scheme.onSurfaceVariant, scheme.surface),
          'onSurface/surfaceContainerHighest': (
            scheme.onSurface,
            scheme.surfaceContainerHighest,
          ),
          'onPrimary/primary': (scheme.onPrimary, scheme.primary),
          'onPrimaryContainer/primaryContainer': (
            scheme.onPrimaryContainer,
            scheme.primaryContainer,
          ),
          'onSecondaryContainer/secondaryContainer': (
            scheme.onSecondaryContainer,
            scheme.secondaryContainer,
          ),
          'onError/error': (scheme.onError, scheme.error),
          'onErrorContainer/errorContainer': (
            scheme.onErrorContainer,
            scheme.errorContainer,
          ),
        };
        for (final pair in pairs.entries) {
          expect(
            _contrast(pair.value.$1, pair.value.$2),
            greaterThanOrEqualTo(4.5),
            reason: pair.key,
          );
        }
      });

      test('semantic color pairs reach WCAG AA 4.5:1', () {
        final c = tokens.colors;
        final pairs = <String, (Color, Color)>{
          'onSuccess/success': (c.onSuccess, c.success),
          'onSuccessContainer/successContainer': (
            c.onSuccessContainer,
            c.successContainer,
          ),
          'onWarning/warning': (c.onWarning, c.warning),
          'onWarningContainer/warningContainer': (
            c.onWarningContainer,
            c.warningContainer,
          ),
          'onInfo/info': (c.onInfo, c.info),
          'onInfoContainer/infoContainer': (c.onInfoContainer, c.infoContainer),
        };
        for (final pair in pairs.entries) {
          expect(
            _contrast(pair.value.$1, pair.value.$2),
            greaterThanOrEqualTo(4.5),
            reason: pair.key,
          );
        }
      });

      test('body text uses onSurface', () {
        expect(theme.textTheme.bodyMedium?.color, scheme.onSurface);
        expect(theme.textTheme.bodyLarge?.color, scheme.onSurface);
      });

      test('tokens extension is registered', () {
        expect(theme.extension<AppTokens>(), isNotNull);
        expect(tokens.spacing.lg, 16);
        expect(tokens.radius.md, 12);
        expect(tokens.durations.fast.inMilliseconds, 150);
      });
    });
  }

  test('dark surfaces are dark tonal surfaces, not inverted light ones', () {
    final dark = buildDarkTheme().colorScheme;
    final light = buildLightTheme().colorScheme;
    expect(dark.surface.computeLuminance(), lessThan(0.05));
    expect(light.surface.computeLuminance(), greaterThan(0.9));
    expect(dark.primary, isNot(equals(light.primary)));
  });

  test('both themes share the seed-derived primary hue', () {
    // Same seed => same tonal family; only the tone differs per brightness.
    final light = buildLightTheme().colorScheme;
    final dark = buildDarkTheme().colorScheme;
    expect(
      HSLColor.fromColor(light.primary).hue,
      closeTo(HSLColor.fromColor(dark.primary).hue, 15),
    );
  });
}

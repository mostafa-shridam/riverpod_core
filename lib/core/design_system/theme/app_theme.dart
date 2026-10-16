import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/tokens/app_tokens.dart';
import 'package:riverpod_core/core/design_system/tokens/app_typography.dart';
import 'package:riverpod_core/core/design_system/tokens/brand_config.dart';

/// Light M3 theme derived from [brandSeedColor].
ThemeData buildLightTheme() => _buildTheme(Brightness.light);

/// Dark M3 theme derived from [brandSeedColor]. Surfaces and containers come
/// from the dark tonal palette, not from inverting the light colors.
ThemeData buildDarkTheme() => _buildTheme(Brightness.dark);

ThemeData _buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: brandSeedColor,
    brightness: brightness,
  );
  final tokens = brightness == Brightness.dark
      ? AppTokens.dark
      : AppTokens.light;
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: buildAppTextTheme(scheme),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
      ),
    ),
    extensions: [tokens],
  );
}

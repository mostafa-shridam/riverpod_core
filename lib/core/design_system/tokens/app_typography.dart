import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/tokens/brand_config.dart';

/// Material 3 type scale, colored from the scheme and set in the brand font.
/// Features never set font sizes; they use `Theme.of(context).textTheme`.
TextTheme buildAppTextTheme(ColorScheme scheme) {
  final typography = Typography.material2021();
  final base = scheme.brightness == Brightness.dark
      ? typography.white
      : typography.black;
  return base.apply(
    fontFamily: brandFontFamily,
    displayColor: scheme.onSurface,
    bodyColor: scheme.onSurface,
  );
}

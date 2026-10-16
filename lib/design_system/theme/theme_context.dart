import 'package:flutter/material.dart';

import 'package:riverpod_core/design_system/tokens/app_tokens.dart';

extension AppThemeContext on BuildContext {
  /// Design tokens of the active theme. Requires a theme built by
  /// `buildLightTheme()` or `buildDarkTheme()`.
  AppTokens get tokens {
    final tokens = Theme.of(this).extension<AppTokens>();
    assert(
      tokens != null,
      'AppTokens missing: build the app theme with buildLightTheme() or '
      'buildDarkTheme()',
    );
    return tokens!;
  }
}

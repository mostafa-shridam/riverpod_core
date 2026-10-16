import 'package:flutter/material.dart';

import 'package:riverpod_core/design_system/theme/theme_context.dart';

/// Status shared by alerts, toasts and banners.
enum AppStatusType { info, success, warning, error }

/// Resolved colors of one [AppStatusType] in the active theme.
@immutable
class AppStatusColors {
  const AppStatusColors({
    required this.accent,
    required this.container,
    required this.onContainer,
  });

  /// Icon / emphasis color.
  final Color accent;

  /// Soft background.
  final Color container;

  /// Text on [container].
  final Color onContainer;
}

extension AppStatusTypeStyle on AppStatusType {
  /// Rounded icon that stays readable at small sizes.
  IconData get icon => switch (this) {
    AppStatusType.info => Icons.info_rounded,
    AppStatusType.success => Icons.check_circle_rounded,
    AppStatusType.warning => Icons.warning_amber_rounded,
    AppStatusType.error => Icons.error_rounded,
  };

  AppStatusColors colorsOf(BuildContext context) {
    final semantic = context.tokens.colors;
    final scheme = Theme.of(context).colorScheme;
    return switch (this) {
      AppStatusType.info => AppStatusColors(
        accent: semantic.info,
        container: semantic.infoContainer,
        onContainer: semantic.onInfoContainer,
      ),
      AppStatusType.success => AppStatusColors(
        accent: semantic.success,
        container: semantic.successContainer,
        onContainer: semantic.onSuccessContainer,
      ),
      AppStatusType.warning => AppStatusColors(
        accent: semantic.warning,
        container: semantic.warningContainer,
        onContainer: semantic.onWarningContainer,
      ),
      AppStatusType.error => AppStatusColors(
        accent: scheme.error,
        container: scheme.errorContainer,
        onContainer: scheme.onErrorContainer,
      ),
    };
  }
}

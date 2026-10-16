import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/generated/locale_keys.g.dart';

enum Thememode {
  light('Light'),
  dark('Dark'),
  system('System');

  const Thememode(this.displayName);
  final String displayName;

  static Thememode fromString(String? value) {
    if (value == null) return Thememode.system;

    return Thememode.values.firstWhere(
      (mode) => mode.name == value || mode.displayName == value,
      orElse: () => Thememode.system,
    );
  }

  static ThemeMode fromThememode(Thememode themeMode) {
    switch (themeMode) {
      case Thememode.light:
        return ThemeMode.light;
      case Thememode.dark:
        return ThemeMode.dark;
      case Thememode.system:
        return ThemeMode.system;
    }
  }

  String get toStr => name;
}

extension ThemeModeExtension on Thememode {
  String get displayName => this.displayName;

  ThemeMode get flutterThemeMode {
    switch (this) {
      case Thememode.light:
        return ThemeMode.light;
      case Thememode.dark:
        return ThemeMode.dark;
      case Thememode.system:
        return ThemeMode.system;
    }
  }

  String get displayNameLocalized {
    switch (this) {
      case Thememode.light:
        return LocaleKeys.light.tr();
      case Thememode.dark:
        return LocaleKeys.dark.tr();
      case Thememode.system:
        return LocaleKeys.system.tr();
    }
  }

  static Thememode get defaultTheme => Thememode.system;
}

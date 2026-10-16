import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/generated/locale_keys.g.dart';

enum Language {
  arabic('ar'),
  english('en');

  const Language(this.displayName);
  final String displayName;

  static Language fromString(String? value) {
    if (value == null) return Language.english;

    return Language.values.firstWhere(
      (language) => language.name == value || language.displayName == value,
      orElse: () => Language.english,
    );
  }

  String get toStr => name;

  /// The locale for this language (`ar` / `en`).
  Locale get locale => Locale(displayName);

  /// Language name written in its own language, shown in the switcher.
  String get nativeName => switch (this) {
    Language.arabic => LocaleKeys.common_nativeName_ar.tr(),
    Language.english => LocaleKeys.common_nativeName_en.tr(),
  };

  static Language fromLocale(Locale locale) => fromString(locale.languageCode);

  static String getLanguageName(Language language) {
    switch (language) {
      case Language.arabic:
        return LocaleKeys.arabic.tr();
      case Language.english:
        return LocaleKeys.english.tr();
    }
  }

  static String getOppositeLanguageName(Language language) {
    switch (language) {
      case Language.arabic:
        return LocaleKeys.english.tr();
      case Language.english:
        return LocaleKeys.arabic.tr();
    }
  }

  static Locale getLanguageLocale(Language language) {
    switch (language) {
      case Language.arabic:
        return const Locale('ar');
      case Language.english:
        return const Locale('en');
    }
  }
}

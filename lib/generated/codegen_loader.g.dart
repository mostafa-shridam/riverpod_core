// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes, avoid_renaming_method_parameters, constant_identifier_names

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader {
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String, dynamic> _en = {
    "hello": "Hello",
    "arabic": "Arabic",
    "english": "English",
    "light": "Light",
    "dark": "Dark",
    "system": "System",
    "confirmButton": "Confirm",
    "cancelButton": "Cancel",
    "selectLanguage": "Select Language",
    "goodEvening": "Good Evening",
    "goodMorning": "Good Morning",
  };
  static const Map<String, dynamic> _ar = {
    "hello": "مرحبا",
    "arabic": "العربية",
    "english": "الإنجليزية",
    "light": "فاتح",
    "dark": "غامق",
    "system": "النظام",
    "confirmButton": "تأكيد",
    "cancelButton": "إلغاء",
    "selectLanguage": "اختر اللغة",
    "goodEvening": "مساء الخير",
    "goodMorning": "صباح الخير",
  };
  static const Map<String, Map<String, dynamic>> mapLocales = {
    "en": _en,
    "ar": _ar,
  };
}

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/constants.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/l10n/app_formatters.dart';

part 'locale_controller.g.dart';

/// Picks the locale to start with: the saved choice, else the first device
/// locale whose language is supported, else English.
Locale resolveStartLocale({
  required String? saved,
  required Iterable<Locale> deviceLocales,
  List<Locale> supported = supportedLocales,
}) {
  Locale? match(String? code) {
    for (final locale in supported) {
      if (locale.languageCode == code) return locale;
    }
    return null;
  }

  final fromSaved = match(saved);
  if (fromSaved != null) return fromSaved;
  for (final device in deviceLocales) {
    final fromDevice = match(device.languageCode);
    if (fromDevice != null) return fromDevice;
  }
  return const Locale('en');
}

/// The user's chosen locale, persisted in prefs. The UI switches through
/// [changeAppLocale]; this controller is the source of truth for the choice.
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  Future<Locale> build() async {
    final prefs = await ref.watch(prefsStorageProvider.future);
    return resolveStartLocale(
      saved: prefs.locale,
      deviceLocales: PlatformDispatcher.instance.locales,
    );
  }

  /// Saves [locale] and publishes it. Unsupported languages are ignored.
  Future<void> setLocale(Locale locale) async {
    final resolved = resolveStartLocale(
      saved: locale.languageCode,
      deviceLocales: const [],
    );
    final prefs = await ref.read(prefsStorageProvider.future);
    await prefs.setLocale(resolved.languageCode);
    state = AsyncData(resolved);
  }
}

/// Formatters for the current locale. Falls back to English while the saved
/// locale is still loading.
@Riverpod(keepAlive: true)
AppFormatters appFormatters(Ref ref) {
  final locale = ref.watch(localeControllerProvider).value;
  return AppFormatters(locale?.languageCode ?? 'en');
}

/// Switches the UI language at runtime (no restart) and persists it.
/// Call from a widget: `changeAppLocale(context, ref.read(localeControllerProvider.notifier), locale)`.
Future<void> changeAppLocale(
  BuildContext context,
  LocaleController controller,
  Locale locale,
) async {
  await context.setLocale(locale);
  await controller.setLocale(locale);
}

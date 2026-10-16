import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/l10n/locale_controller.dart';

import '../helpers/create_container.dart';
import '../helpers/fake_prefs_storage.dart';

void main() {
  group('resolveStartLocale', () {
    const ar = Locale('ar', 'EG');
    const fr = Locale('fr');

    test('saved choice wins over the device', () {
      expect(
        resolveStartLocale(saved: 'ar', deviceLocales: const [Locale('en')]),
        const Locale('ar'),
      );
    });
    test('device locale when nothing saved and supported', () {
      expect(
        resolveStartLocale(saved: null, deviceLocales: const [fr, ar]),
        const Locale('ar'),
      );
    });
    test('en when device is unsupported or empty', () {
      expect(
        resolveStartLocale(saved: null, deviceLocales: const [fr]),
        const Locale('en'),
      );
      expect(
        resolveStartLocale(saved: null, deviceLocales: const []),
        const Locale('en'),
      );
    });
    test('unsupported saved value falls through to the device', () {
      expect(
        resolveStartLocale(saved: 'xx', deviceLocales: const [ar]),
        const Locale('ar'),
      );
    });
  });

  group('LocaleController', () {
    test('reads the saved locale', () async {
      final prefs = await fakePrefsStorage({PrefKeys.locale: 'ar'});
      final container = createContainer(
        overrides: [prefsStorageProvider.overrideWith((ref) => prefs)],
      );
      expect(
        await container.read(localeControllerProvider.future),
        const Locale('ar'),
      );
    });

    test('setLocale persists and survives a new container', () async {
      final prefs = await fakePrefsStorage();
      final overrides = [prefsStorageProvider.overrideWith((ref) => prefs)];
      final first = createContainer(overrides: overrides);
      await first.read(localeControllerProvider.future);
      await first
          .read(localeControllerProvider.notifier)
          .setLocale(const Locale('ar'));
      expect(first.read(localeControllerProvider).value, const Locale('ar'));
      expect(prefs.locale, 'ar');

      final second = createContainer(overrides: overrides);
      expect(
        await second.read(localeControllerProvider.future),
        const Locale('ar'),
      );
    });

    test('unsupported locale is never stored', () async {
      final prefs = await fakePrefsStorage({PrefKeys.locale: 'ar'});
      final container = createContainer(
        overrides: [prefsStorageProvider.overrideWith((ref) => prefs)],
      );
      await container.read(localeControllerProvider.future);
      await container
          .read(localeControllerProvider.notifier)
          .setLocale(const Locale('fr'));
      // fr resolves to the English fallback, never to an unsupported value.
      expect(prefs.locale, 'en');
    });

    test('appFormatters follows the locale', () async {
      final prefs = await fakePrefsStorage({PrefKeys.locale: 'ar'});
      final container = createContainer(
        overrides: [prefsStorageProvider.overrideWith((ref) => prefs)],
      );
      await container.read(localeControllerProvider.future);
      expect(container.read(appFormattersProvider).locale, 'ar');
    });
  });
}

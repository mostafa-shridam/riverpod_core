import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/features/onboarding/data/onboarding_slides.dart';
import 'package:riverpod_core/features/onboarding/providers/onboarding_controller.dart';

import '../../helpers/helpers.dart';

void main() {
  Future<(ProviderContainer, PrefsStorage)> setUp() async {
    final prefs = await fakePrefsStorage();
    final container = createContainer(
      overrides: [
        prefsStorageProvider.overrideWith((ref) => Future.value(prefs)),
      ],
    );
    return (container, prefs);
  }

  test('starts on the first slide', () async {
    final (container, _) = await setUp();
    addTearDown(container.dispose);

    expect(container.read(onboardingControllerProvider), 0);
  });

  test('select keeps the index inside the slides', () async {
    final (container, _) = await setUp();
    addTearDown(container.dispose);
    final controller = container.read(onboardingControllerProvider.notifier);

    controller.select(2);
    expect(container.read(onboardingControllerProvider), 2);

    controller.select(99);
    expect(
      container.read(onboardingControllerProvider),
      onboardingSlides.length - 1,
    );

    controller.select(-3);
    expect(container.read(onboardingControllerProvider), 0);
  });

  test('next advances without storing the flag', () async {
    final (container, prefs) = await setUp();
    addTearDown(container.dispose);

    await container.read(onboardingControllerProvider.notifier).next();

    expect(container.read(onboardingControllerProvider), 1);
    expect(prefs.onboardingSeen, isFalse);
  });

  test('next on the last slide stores that onboarding was seen', () async {
    final (container, prefs) = await setUp();
    addTearDown(container.dispose);
    final controller = container.read(onboardingControllerProvider.notifier);
    controller.select(onboardingSlides.length - 1);

    await controller.next();

    expect(prefs.onboardingSeen, isTrue);
  });

  test('finish stores the flag from any slide (skip)', () async {
    final (container, prefs) = await setUp();
    addTearDown(container.dispose);

    await container.read(onboardingControllerProvider.notifier).finish();

    expect(prefs.onboardingSeen, isTrue);
  });
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/features/onboarding/data/onboarding_slides.dart';

part 'onboarding_controller.g.dart';

/// Carousel state: the index of the slide shown now. Finishing stores the
/// onboarding-seen flag; the router then leaves onboarding by itself.
@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  int build() => 0;

  /// Shows slide [index], kept inside the slides.
  void select(int index) {
    state = index.clamp(0, onboardingSlides.length - 1);
  }

  /// Next slide, or finish on the last one.
  Future<void> next() {
    if (state >= onboardingSlides.length - 1) return finish();
    state++;
    return Future<void>.value();
  }

  /// Stores that onboarding was seen. Skip and "get started" both end here.
  Future<void> finish() async {
    final prefs = await ref.read(prefsStorageProvider.future);
    await prefs.setOnboardingSeen(value: true);
    ref.invalidate(prefsStorageProvider);
  }
}

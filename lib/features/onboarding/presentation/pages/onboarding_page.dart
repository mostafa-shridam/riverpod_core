import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/app_status_type.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/snackbar/app_snackbar.dart';
import 'package:riverpod_core/core/errors/error_mapper.dart';
import 'package:riverpod_core/core/errors/error_messages.dart';
import 'package:riverpod_core/features/onboarding/data/onboarding_slides.dart';
import 'package:riverpod_core/features/onboarding/presentation/widgets/onboarding_dots.dart';
import 'package:riverpod_core/features/onboarding/presentation/widgets/onboarding_slide_view.dart';
import 'package:riverpod_core/features/onboarding/providers/onboarding_controller.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// First-run carousel. Skip and "get started" store the onboarding-seen flag.
/// Swipes follow the text direction (PageView mirrors in RTL).
class OnboardingPage extends ConsumerStatefulWidget {
  static const routeName = '/onboarding';

  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pages = PageController();

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stackTrace) {
      if (!mounted) return;
      showAppSnackbar(
        context,
        message: errorMessageKey(mapError(error, stackTrace)).tr(),
        type: AppStatusType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final tokens = context.tokens;
    final isLast = index == onboardingSlides.length - 1;

    // Buttons move the carousel; swipes already moved it and report back.
    ref.listen(onboardingControllerProvider, (previous, next) {
      if (_pages.hasClients && _pages.page?.round() != next) {
        _pages.animateToPage(
          next,
          duration: tokens.durations.normal,
          curve: tokens.durations.standardCurve,
        );
      }
    });

    return Scaffold(
      key: const ValueKey('onboarding-page'),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: EdgeInsets.all(tokens.spacing.sm),
                // Keeps the row height on the last slide, so nothing jumps.
                child: isLast
                    ? const SizedBox(height: 48)
                    : AppButton(
                        label: LocaleKeys.onboarding_skip.tr(),
                        variant: AppButtonVariant.text,
                        onPressed: () => _run(controller.finish),
                      ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: onboardingSlides.length,
                onPageChanged: controller.select,
                itemBuilder: (context, i) =>
                    OnboardingSlideView(slide: onboardingSlides[i]),
              ),
            ),
            OnboardingDots(count: onboardingSlides.length, index: index),
            SizedBox(height: tokens.spacing.lg),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.spacing.lg),
              child: AppButton(
                label: isLast
                    ? LocaleKeys.onboarding_getStarted.tr()
                    : LocaleKeys.onboarding_next.tr(),
                fullWidth: true,
                onPressed: () => _run(controller.next),
              ),
            ),
            SizedBox(height: tokens.spacing.lg),
          ],
        ),
      ),
    );
  }
}

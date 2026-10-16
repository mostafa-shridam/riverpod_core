import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

/// Temporary onboarding page. TODO(C-18): the real carousel replaces it.
class OnboardingPage extends ConsumerWidget {
  static const routeName = '/onboarding';

  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      key: const ValueKey('onboarding-page'),
      body: Center(
        child: AppButton(
          label: 'app_nav.continue'.tr(),
          onPressed: () async {
            final prefs = await ref.read(prefsStorageProvider.future);
            await prefs.setOnboardingSeen(value: true);
            ref.invalidate(prefsStorageProvider);
          },
        ),
      ),
    );
  }
}

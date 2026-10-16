import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

// Temporary pages so the router has real destinations. C-17 (login) and
// C-18 (onboarding) replace them. Each one is keyed so tests can find it.

class OnboardingPage extends ConsumerWidget {
  static const routeName = '/onboarding';

  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      key: const ValueKey('onboarding-page'),
      body: Center(
        // TODO(C-18): real onboarding; this stub only marks it as seen.
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

class LoginPage extends ConsumerWidget {
  static const routeName = '/login';

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      key: const ValueKey('login-page'),
      body: Center(
        // TODO(C-17): real sign-in; this stub signs in without credentials.
        child: AppButton(
          label: 'app_nav.continue'.tr(),
          onPressed: () =>
              ref.read(sessionControllerProvider.notifier).signIn(),
        ),
      ),
    );
  }
}

class MorePage extends StatelessWidget {
  static const routeName = '/more';

  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(key: ValueKey('more-page'));
  }
}

class ItemDetailPage extends StatelessWidget {
  static const routeName = '/items';

  const ItemDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('item-detail-page'),
      body: Center(child: Text(id)),
    );
  }
}

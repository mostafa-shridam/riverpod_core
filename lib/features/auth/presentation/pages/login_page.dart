import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';

/// Temporary sign-in page. TODO(C-17): the real login replaces it.
class LoginPage extends ConsumerWidget {
  static const routeName = '/login';

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      key: const ValueKey('login-page'),
      body: Center(
        child: AppButton(
          label: 'app_nav.continue'.tr(),
          onPressed: () =>
              ref.read(sessionControllerProvider.notifier).signIn(),
        ),
      ),
    );
  }
}

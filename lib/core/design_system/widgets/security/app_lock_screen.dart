import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/widgets/async/empty_state.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Opaque full-screen cover that hides the app while it is locked or in the
/// app switcher. Without [onUnlock] it only covers (no button).
class AppLockScreen extends StatelessWidget {
  const AppLockScreen({super.key, this.onUnlock, this.message});

  /// Shows the unlock button when set.
  final VoidCallback? onUnlock;

  /// Defaults to `security.lock.message`.
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const ValueKey('app-lock-screen'),
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: EmptyState(
              icon: Icons.lock_outline_rounded,
              title: LocaleKeys.security_lock_title.tr(),
              message: message ?? LocaleKeys.security_lock_message.tr(),
              actionLabel: LocaleKeys.security_lock_unlock.tr(),
              onAction: onUnlock,
            ),
          ),
        ),
      ),
    );
  }
}

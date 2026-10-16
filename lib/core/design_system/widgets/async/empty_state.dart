import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/widgets/async/state_illustration.dart';
import 'package:riverpod_core/core/design_system/widgets/async/state_message.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Success with zero items: illustration, message and an optional action.
/// All texts default to localized copy; pass your own for specific pages.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.title,
    this.message,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
  });

  /// Defaults to `ds_async.emptyTitle`.
  final String? title;

  /// Defaults to `ds_async.emptyMessage`.
  final String? message;
  final IconData icon;

  /// The action shows only when both [actionLabel] and [onAction] are set.
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return StateMessage(
      illustration: StateIllustration(
        icon: icon,
        accent: scheme.primary,
        container: scheme.primaryContainer,
        onContainer: scheme.onPrimaryContainer,
      ),
      title: title ?? LocaleKeys.ds_async_emptyTitle.tr(),
      message: message ?? LocaleKeys.ds_async_emptyMessage.tr(),
      action: actionLabel != null && onAction != null
          ? AppButton(
              label: actionLabel!,
              onPressed: onAction,
              variant: AppButtonVariant.tonal,
            )
          : null,
    );
  }
}

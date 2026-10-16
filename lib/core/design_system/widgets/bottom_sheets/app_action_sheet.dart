import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/bottom_sheets/app_bottom_sheet.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// One row of an [AppActionSheet]. [value] is what the sheet returns.
@immutable
class AppSheetAction<T> {
  const AppSheetAction({
    required this.label,
    required this.value,
    this.icon,
    this.subtitle,
    this.isDestructive = false,
    this.enabled = true,
  });

  final String label;
  final T value;
  final IconData? icon;
  final String? subtitle;

  /// Painted with the error color and separated from the other actions.
  final bool isDestructive;
  final bool enabled;
}

/// List of actions with icons, destructive items and a cancel button.
/// Pops with the tapped action's value, or null on cancel.
class AppActionSheet<T> extends StatelessWidget {
  const AppActionSheet({
    required this.actions,
    super.key,
    this.message,
    this.showCancel = true,
    this.cancelLabel,
  });

  final List<AppSheetAction<T>> actions;

  /// Optional line under the title.
  final String? message;
  final bool showCancel;

  /// Overrides the localized "cancel" label.
  final String? cancelLabel;

  /// Opens the sheet; the result is the chosen action's value or null.
  static Future<T?> show<T>({
    required BuildContext context,
    required List<AppSheetAction<T>> actions,
    String? title,
    String? message,
    bool showCancel = true,
    String? cancelLabel,
  }) {
    return showAppBottomSheet<T>(
      context: context,
      title: title,
      builder: (_) => AppActionSheet<T>(
        actions: actions,
        message: message,
        showCancel: showCancel,
        cancelLabel: cancelLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final normal = actions.where((a) => !a.isDestructive).toList();
    final destructive = actions.where((a) => a.isDestructive).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (message != null)
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: tokens.spacing.sm,
              end: tokens.spacing.sm,
              bottom: tokens.spacing.sm,
            ),
            child: Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        for (final action in normal) _ActionTile<T>(action: action),
        if (destructive.isNotEmpty && normal.isNotEmpty)
          Padding(
            padding: EdgeInsetsDirectional.symmetric(
              vertical: tokens.spacing.xs,
            ),
            child: const Divider(height: 1),
          ),
        for (final action in destructive) _ActionTile<T>(action: action),
        if (showCancel)
          Padding(
            padding: EdgeInsetsDirectional.only(top: tokens.spacing.md),
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(kMinInteractiveDimension),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(cancelLabel ?? LocaleKeys.ds_overlays_cancel.tr()),
            ),
          ),
      ],
    );
  }
}

class _ActionTile<T> extends StatelessWidget {
  const _ActionTile({required this.action});

  final AppSheetAction<T> action;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final color = action.isDestructive ? scheme.error : scheme.onSurface;
    return ListTile(
      enabled: action.enabled,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
      ),
      leading: action.icon == null
          ? null
          : Icon(
              action.icon,
              color: action.enabled
                  ? (action.isDestructive ? scheme.error : scheme.primary)
                  : null,
            ),
      title: Text(action.label),
      subtitle: action.subtitle == null ? null : Text(action.subtitle!),
      textColor: color,
      onTap: () => Navigator.of(context).pop(action.value),
    );
  }
}

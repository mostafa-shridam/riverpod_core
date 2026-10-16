import 'package:flutter/material.dart';

import 'package:riverpod_core/design_system/theme/theme_context.dart';

/// Color meaning of an [AppChip].
enum AppChipTone { neutral, primary, success, warning, error, info }

/// Compact label. Behaves as a filter chip when [onSelected] is set, as an
/// input chip when only [onDeleted] is set, as an action chip when only
/// [onTap] is set, and as a plain tag otherwise.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.icon,
    this.avatar,
    this.tone = AppChipTone.neutral,
    this.selected = false,
    this.onSelected,
    this.onTap,
    this.onDeleted,
    this.deleteTooltip,
  });

  final String label;
  final IconData? icon;

  /// Replaces [icon] with any leading widget (for example an `AppAvatar`).
  final Widget? avatar;
  final AppChipTone tone;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  /// Tooltip and semantics of the delete icon; pass a localized string.
  final String? deleteTooltip;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = tokens.colors;
    final (container, onContainer) = switch (tone) {
      AppChipTone.neutral => (
        scheme.surfaceContainerHigh,
        scheme.onSurfaceVariant,
      ),
      AppChipTone.primary => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      AppChipTone.success => (
        colors.successContainer,
        colors.onSuccessContainer,
      ),
      AppChipTone.warning => (
        colors.warningContainer,
        colors.onWarningContainer,
      ),
      AppChipTone.error => (scheme.errorContainer, scheme.onErrorContainer),
      AppChipTone.info => (colors.infoContainer, colors.onInfoContainer),
    };
    final isFilter = onSelected != null;
    // Selected filters use the strong tone color; unselected stay outlined.
    final background = isFilter && !selected ? scheme.surface : container;
    final foreground = isFilter && !selected
        ? scheme.onSurfaceVariant
        : onContainer;
    final leading =
        avatar ??
        (icon == null ? null : Icon(icon, size: 18, color: foreground));
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radius.sm),
      side: isFilter && !selected
          ? BorderSide(color: scheme.outlineVariant)
          : BorderSide.none,
    );
    final labelWidget = Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(color: foreground),
    );
    final deleteIcon = onDeleted == null
        ? null
        : Icon(Icons.close, size: 18, color: foreground);

    return RawChip(
      label: labelWidget,
      avatar: leading,
      selected: selected,
      onSelected: onSelected,
      onPressed: onTap,
      onDeleted: onDeleted,
      deleteIcon: deleteIcon,
      deleteButtonTooltipMessage: deleteTooltip,
      showCheckmark: false,
      backgroundColor: background,
      selectedColor: container,
      disabledColor: background,
      side: BorderSide.none,
      shape: shape,
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.xs,
        vertical: tokens.spacing.xs,
      ),
      labelPadding: EdgeInsets.symmetric(horizontal: tokens.spacing.xs),
      elevation: tokens.elevation.none,
      pressElevation: tokens.elevation.none,
    );
  }
}

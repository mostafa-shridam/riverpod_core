import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_form_field.dart';

/// One segment of an [AppSegmentedControl].
@immutable
class AppSegment<T> {
  const AppSegment({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  final T value;
  final String label;
  final IconData? icon;
  final bool enabled;
}

/// Pill-shaped single choice control with equal-width segments. Labels wrap
/// instead of overflowing at large text scales. The selected segment shows a
/// check so the state is not carried by color alone.
/// Controlled: pass [value] and update it in [onChanged].
class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    required this.segments,
    required this.value,
    required this.onChanged,
    super.key,
    this.label,
    this.helper,
    this.validator,
    this.errorText,
    this.enabled = true,
  });

  final List<AppSegment<T>> segments;
  final T? value;

  /// Null disables the control.
  final ValueChanged<T>? onChanged;
  final String? label;
  final String? helper;
  final FormFieldValidator<T>? validator;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final active = enabled && onChanged != null;
    final outline = BorderSide(
      color: active ? scheme.outline : scheme.onSurface.withValues(alpha: 0.12),
      width: tokens.sizes.outlineWidth,
    );
    final radius = BorderRadius.circular(tokens.radius.full);

    return AppFormField<T>(
      value: value,
      label: label,
      helper: helper,
      enabled: active,
      validator: validator,
      forceErrorText: errorText,
      builder: (state) {
        final side = state.hasError
            ? outline.copyWith(color: scheme.error)
            : outline;
        return Semantics(
          container: true,
          explicitChildNodes: true,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.fromBorderSide(side),
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < segments.length; i++)
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: i == 0
                                ? null
                                : BorderDirectional(start: side),
                          ),
                          child: _Segment(
                            label: segments[i].label,
                            icon: segments[i].icon,
                            selected: segments[i].value == value,
                            enabled: active && segments[i].enabled,
                            onTap: () {
                              final next = segments[i].value;
                              state.didChange(next);
                              onChanged!(next);
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = !enabled
        ? scheme.onSurface.withValues(alpha: 0.38)
        : selected
        ? scheme.onSecondaryContainer
        : scheme.onSurface;
    final leading = selected ? Icons.check_rounded : icon;

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      inMutuallyExclusiveGroup: true,
      label: label,
      onTap: enabled ? onTap : null,
      excludeSemantics: true,
      child: Material(
        color: selected ? scheme.secondaryContainer : Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: tokens.sizes.minTouchTarget),
            child: Center(
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: tokens.spacing.md,
                  vertical: tokens.spacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leading != null) ...[
                      Icon(
                        leading,
                        size: tokens.sizes.iconSm,
                        color: foreground,
                      ),
                      SizedBox(width: tokens.spacing.xs),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/design_system/widgets/display/display_strings.dart';

/// Expandable section: tappable header with a rotating chevron, animated
/// content. Content is not built while collapsed.
class AppAccordion extends StatefulWidget {
  const AppAccordion({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.leading,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.expandLabel,
    this.collapseLabel,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget child;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;

  /// Override the localized screen-reader hints.
  final String? expandLabel;
  final String? collapseLabel;

  @override
  State<AppAccordion> createState() => _AppAccordionState();
}

class _AppAccordionState extends State<AppAccordion> {
  late bool _expanded = widget.initiallyExpanded;

  void _toggle() {
    setState(() => _expanded = !_expanded);
    widget.onExpansionChanged?.call(_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radius.lg),
      side: BorderSide(color: scheme.outlineVariant),
    );
    final hint = _expanded
        ? widget.collapseLabel ?? dsDisplayCollapseKey.tr()
        : widget.expandLabel ?? dsDisplayExpandKey.tr();

    return Material(
      color: scheme.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            expanded: _expanded,
            onTapHint: hint,
            child: InkWell(
              onTap: _toggle,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: tokens.spacing.lg,
                    vertical: tokens.spacing.md,
                  ),
                  child: Row(
                    children: [
                      if (widget.leading != null) ...[
                        IconTheme.merge(
                          data: IconThemeData(color: scheme.primary),
                          child: widget.leading!,
                        ),
                        SizedBox(width: tokens.spacing.md),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: scheme.onSurface,
                              ),
                            ),
                            if (widget.subtitle != null)
                              Text(
                                widget.subtitle!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: tokens.spacing.sm),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: tokens.durations.normal,
                        curve: Curves.easeOut,
                        child: Icon(
                          Icons.expand_more,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: tokens.durations.normal,
            curve: Curves.easeOut,
            alignment: AlignmentDirectional.topStart,
            child: _expanded
                ? Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: tokens.spacing.lg,
                      end: tokens.spacing.lg,
                      bottom: tokens.spacing.lg,
                    ),
                    child: widget.child,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';

/// A small captioned row of demo widgets. Children wrap onto new lines, so a
/// group survives narrow screens and a 2.0x text scale.
class ShowcaseGroup extends StatelessWidget {
  const ShowcaseGroup({required this.label, required this.children, super.key});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final spacing = context.tokens.spacing;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: spacing.sm),
        Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: children,
        ),
      ],
    );
  }
}

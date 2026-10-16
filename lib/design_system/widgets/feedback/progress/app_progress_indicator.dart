import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/design_system/widgets/feedback/feedback_strings.dart';

enum AppProgressSize { sm, md, lg }

/// Circular progress. `value` 0..1 is determinate, null is indeterminate.
class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({
    super.key,
    this.value,
    this.size = AppProgressSize.md,
    this.color,
    this.semanticLabel,
  }) : assert(value == null || (value >= 0 && value <= 1));

  final double? value;
  final AppProgressSize size;
  final Color? color;

  /// Overrides the localized "progress" announcement.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final spacing = tokens.spacing;
    final (dimension, stroke) = switch (size) {
      AppProgressSize.sm => (spacing.lg, spacing.xxs),
      AppProgressSize.md => (spacing.xl + spacing.sm, spacing.xs),
      AppProgressSize.lg => (spacing.xxxl, spacing.xs),
    };
    return Semantics(
      label: semanticLabel ?? progressLabelKey.tr(),
      value: value == null ? null : '${(value! * 100).round()}%',
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: dimension,
          child: CircularProgressIndicator(
            value: value,
            strokeWidth: stroke,
            strokeCap: StrokeCap.round,
            color: color ?? scheme.primary,
            backgroundColor: value == null
                ? null
                : scheme.surfaceContainerHighest,
          ),
        ),
      ),
    );
  }
}

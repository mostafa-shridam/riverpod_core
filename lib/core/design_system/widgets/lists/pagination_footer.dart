import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/design_system/widgets/lists/lists_strings.dart';

/// What the footer of a paginated list shows after the last item.
enum PaginationFooterStatus { none, loading, end, error }

/// Footer row of [PaginatedListView]: loader, end of list, or an error with retry.
class PaginationFooter extends StatelessWidget {
  const PaginationFooter({
    super.key,
    required this.status,
    this.errorText,
    this.onRetry,
  });

  final PaginationFooterStatus status;

  /// Already localized message for [PaginationFooterStatus.error].
  final String? errorText;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final Widget content = switch (status) {
      PaginationFooterStatus.none => const SizedBox.shrink(),
      PaginationFooterStatus.loading => Semantics(
        liveRegion: true,
        label: dsListsLoadingMoreKey.tr(),
        child: const Center(child: CircularProgressIndicator()),
      ),
      PaginationFooterStatus.end => Center(
        child: Text(
          dsListsEndOfListKey.tr(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      PaginationFooterStatus.error => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            errorText ?? '',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          AppButton(
            label: dsListsRetryKey.tr(),
            variant: AppButtonVariant.tonal,
            onPressed: onRetry,
          ),
        ],
      ),
    };
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        vertical: tokens.spacing.md,
        horizontal: tokens.spacing.lg,
      ),
      child: content,
    );
  }
}

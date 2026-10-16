import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/design_system/widgets/bottom_sheets/app_bottom_sheet.dart';
import 'package:riverpod_core/design_system/widgets/dialogs/overlay_metrics.dart';
import 'package:riverpod_core/design_system/widgets/dialogs/overlays_strings.dart';

/// Title + form content + sticky primary/secondary buttons. The footer stays
/// pinned above the keyboard while the content scrolls.
///
/// Use [AppFormSheet.show] to open it; [onPrimary] receives the sheet's
/// context so the caller decides when to pop (e.g. after validation).
class AppFormSheet {
  const AppFormSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder content,
    required String primaryLabel,
    required void Function(BuildContext sheetContext) onPrimary,
    String? title,
    String? secondaryLabel,
    void Function(BuildContext sheetContext)? onSecondary,
    bool primaryEnabled = true,
    bool isDismissible = true,
  }) {
    return showAppBottomSheet<T>(
      context: context,
      title: title,
      isDismissible: isDismissible,
      builder: content,
      footer: _FormFooter(
        primaryLabel: primaryLabel,
        secondaryLabel: secondaryLabel ?? cancelKey.tr(),
        primaryEnabled: primaryEnabled,
        onPrimary: onPrimary,
        onSecondary: onSecondary,
      ),
    );
  }
}

class _FormFooter extends StatelessWidget {
  const _FormFooter({
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.primaryEnabled,
    required this.onPrimary,
    required this.onSecondary,
  });

  final String primaryLabel;
  final String secondaryLabel;
  final bool primaryEnabled;
  final void Function(BuildContext) onPrimary;
  final void Function(BuildContext)? onSecondary;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    const minSize = Size(0, kMinInteractiveDimension);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: overlayMaxWidth),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: minSize),
              onPressed: () => onSecondary != null
                  ? onSecondary!(context)
                  : Navigator.of(context).pop(),
              child: Text(secondaryLabel, textAlign: TextAlign.center),
            ),
          ),
          SizedBox(width: tokens.spacing.md),
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(minimumSize: minSize),
              onPressed: primaryEnabled ? () => onPrimary(context) : null,
              child: Text(primaryLabel, textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}

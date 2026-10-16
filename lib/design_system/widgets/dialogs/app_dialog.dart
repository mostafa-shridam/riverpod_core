import 'package:flutter/material.dart';

import 'package:riverpod_core/design_system/responsive/breakpoints.dart';
import 'package:riverpod_core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/design_system/widgets/dialogs/overlay_metrics.dart';
import 'package:riverpod_core/design_system/widgets/feedback/app_status_type.dart';

/// Shows the one dialog of the app with the themed scrim. [builder] usually
/// returns an [AppDialogFrame] or one of the presets (`AppAlertDialog`, ...).
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  String? barrierLabel,
}) {
  return showDialog<T>(
    context: context,
    builder: builder,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: overlayScrimColor(context),
    useRootNavigator: useRootNavigator,
  );
}

/// Visual shell of every dialog: rounded `xl` surface, optional status icon on
/// top, title, scrollable body and buttons. Buttons are stacked full width on
/// phones (primary first) and sit side by side at the end on wider screens.
class AppDialogFrame extends StatelessWidget {
  const AppDialogFrame({
    super.key,
    this.title,
    this.message,
    this.content,
    this.status,
    this.icon,
    this.primary,
    this.secondary,
  });

  final String? title;
  final String? message;

  /// Extra body widget under [message] (e.g. a text field).
  final Widget? content;

  /// Draws the status icon in a tinted circle on top.
  final AppStatusType? status;

  /// Custom icon; uses the status colors when [status] is set.
  final IconData? icon;

  /// Main action button.
  final Widget? primary;

  /// Dismissive action button.
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final iconData = icon ?? status?.icon;
    final hasIcon = iconData != null;
    final align = hasIcon ? TextAlign.center : TextAlign.start;
    final cross = hasIcon
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final colors = status?.colorsOf(context);
    final stacked = context.breakpoint == AppBreakpoint.phone;
    final actions = [?primary, ?secondary];

    return Dialog(
      backgroundColor: scheme.surfaceContainerHigh,
      surfaceTintColor: scheme.surfaceTint,
      elevation: tokens.elevation.high,
      // Symmetric on both sides, so no start/end distinction is needed.
      insetPadding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.lg,
        vertical: tokens.spacing.xl,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.xl),
      ),
      child: Semantics(
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        label: title,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: overlayMaxWidth),
          child: Padding(
            padding: EdgeInsetsDirectional.all(tokens.spacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: cross,
              children: [
                if (hasIcon)
                  Container(
                    width: tokens.spacing.xxxl + tokens.spacing.sm,
                    height: tokens.spacing.xxxl + tokens.spacing.sm,
                    margin: EdgeInsetsDirectional.only(
                      bottom: tokens.spacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: colors?.container ?? scheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconData,
                      size: tokens.spacing.xl + tokens.spacing.sm,
                      color: colors?.accent ?? scheme.primary,
                    ),
                  ),
                if (title != null)
                  Semantics(
                    header: true,
                    child: Text(
                      title!,
                      textAlign: align,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: cross,
                      children: [
                        if (message != null)
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              top: title == null ? 0 : tokens.spacing.md,
                            ),
                            child: Text(
                              message!,
                              textAlign: align,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        if (content != null)
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              top: tokens.spacing.lg,
                            ),
                            child: content,
                          ),
                      ],
                    ),
                  ),
                ),
                if (actions.isNotEmpty)
                  Padding(
                    padding: EdgeInsetsDirectional.only(top: tokens.spacing.xl),
                    child: stacked
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < actions.length; i++) ...[
                                if (i > 0) SizedBox(height: tokens.spacing.sm),
                                actions[i],
                              ],
                            ],
                          )
                        : Wrap(
                            alignment: WrapAlignment.end,
                            spacing: tokens.spacing.sm,
                            runSpacing: tokens.spacing.sm,
                            // Secondary left of primary reads naturally.
                            textDirection: Directionality.of(context),
                            children: actions.reversed.toList(),
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Visual shell of every bottom sheet: rounded surface, drag handle, optional
/// title + close button, scrollable body and a sticky footer. Keyboard and
/// safe-area aware, so content never hides behind either.
class AppSheetFrame extends StatelessWidget {
  const AppSheetFrame({
    required this.body,
    super.key,
    this.title,
    this.showCloseButton = false,
    this.closeLabel,
    this.footer,
    this.scrollable = true,
    this.expand = false,
    this.scrollController,
  });

  final Widget body;
  final String? title;
  final bool showCloseButton;

  /// Overrides the localized "close" tooltip.
  final String? closeLabel;

  /// Pinned below the body, above the keyboard.
  final Widget? footer;

  /// Wraps [body] in a scroll view. Turn off when [body] scrolls itself.
  final bool scrollable;

  /// Fills the available height (draggable sheets) instead of hugging content.
  final bool expand;

  /// Scroll controller handed out by a draggable sheet.
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final media = MediaQuery.of(context);
    // Keyboard wins over the home-indicator inset; never add both.
    final bottomInset = media.viewInsets.bottom > 0
        ? media.viewInsets.bottom
        : media.padding.bottom;
    final hasHeader = title != null || showCloseButton;

    Widget content = body;
    if (scrollable) {
      content = SingleChildScrollView(
        controller: scrollController,
        padding: EdgeInsetsDirectional.symmetric(horizontal: tokens.spacing.lg),
        child: body,
      );
    }

    final surface = Material(
      color: scheme.surfaceContainerLow,
      elevation: tokens.elevation.low,
      surfaceTintColor: scheme.surfaceTint,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.vertical(
          top: Radius.circular(tokens.radius.xl),
        ).resolve(Directionality.of(context)),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DragHandle(color: scheme.outline),
            if (hasHeader)
              _Header(
                title: title,
                showClose: showCloseButton,
                closeLabel: closeLabel ?? LocaleKeys.ds_overlays_close.tr(),
              ),
            if (expand) Expanded(child: content) else Flexible(child: content),
            if (footer != null)
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  tokens.spacing.lg,
                  tokens.spacing.md,
                  tokens.spacing.lg,
                  tokens.spacing.lg,
                ),
                child: footer,
              )
            else
              SizedBox(height: tokens.spacing.lg),
          ],
        ),
      ),
    );

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: title,
      child: surface,
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ExcludeSemantics(
      child: Center(
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            top: tokens.spacing.md,
            bottom: tokens.spacing.sm,
          ),
          child: Container(
            width: tokens.spacing.xxl,
            height: tokens.spacing.xs,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(tokens.radius.full),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.showClose,
    required this.closeLabel,
  });

  final String? title;
  final bool showClose;
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: tokens.spacing.lg,
        end: showClose ? tokens.spacing.sm : tokens.spacing.lg,
        bottom: tokens.spacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: title == null
                ? const SizedBox.shrink()
                : Semantics(
                    header: true,
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
          ),
          if (showClose)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: closeLabel,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
        ],
      ),
    );
  }
}

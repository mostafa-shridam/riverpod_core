import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/responsive/breakpoints.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_bottom_nav_bar.dart';

/// Page frame: app bar, adaptive navigation, safe area, content centered
/// with a max width and breakpoint-based side padding, and a slot for an
/// offline banner above the content.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.navigationBar,
    this.banner,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.maxWidth = maxContentWidth,
    this.adaptivePadding = true,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;

  /// Bottom bar on phones, side rail on tablets and desktops.
  final AppBottomNavBar? navigationBar;

  /// Shown full width above the content, for example an `OfflineBanner`.
  /// Collapses with an animation when null.
  final Widget? banner;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;

  /// Content max width; pass `double.infinity` for edge-to-edge content.
  final double maxWidth;

  /// Side padding by width class (lg / xl / xxl). Turn off for lists that
  /// pad their own items.
  final bool adaptivePadding;
  final bool resizeToAvoidBottomInset;

  double _sidePadding(BuildContext context) {
    final spacing = context.tokens.spacing;
    return switch (context.breakpoint) {
      AppBreakpoint.phone => spacing.lg,
      AppBreakpoint.tablet => spacing.xl,
      AppBreakpoint.desktop => spacing.xxl,
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final nav = navigationBar;
    final rail = nav != null && AppBottomNavBar.isRail(context);

    Widget content = body;
    if (adaptivePadding) {
      content = Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: _sidePadding(context),
        ),
        child: content,
      );
    }
    content = Align(
      alignment: AlignmentDirectional.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: content,
      ),
    );

    Widget main = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSize(
          duration: tokens.durations.fast,
          alignment: AlignmentDirectional.topStart,
          child: banner ?? const SizedBox(width: double.infinity),
        ),
        Expanded(child: content),
      ],
    );

    main = SafeArea(
      top: appBar == null,
      bottom: nav == null || rail,
      child: main,
    );

    if (rail) {
      final scheme = Theme.of(context).colorScheme;
      main = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(child: nav),
          VerticalDivider(width: 1, thickness: 1, color: scheme.outlineVariant),
          Expanded(child: main),
        ],
      );
    }

    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: nav != null && !rail ? nav : null,
      body: main,
    );
  }
}

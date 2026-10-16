import 'package:flutter/widgets.dart';

import 'package:riverpod_core/design_system/responsive/breakpoints.dart';

/// Picks a layout by width class. Missing tablet/desktop layouts fall back
/// to the next smaller class, so a phone layout is always the base.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.phone,
    this.tablet,
    this.desktop,
  });

  final Widget phone;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return switch (context.breakpoint) {
      AppBreakpoint.desktop => desktop ?? tablet ?? phone,
      AppBreakpoint.tablet => tablet ?? phone,
      AppBreakpoint.phone => phone,
    };
  }
}

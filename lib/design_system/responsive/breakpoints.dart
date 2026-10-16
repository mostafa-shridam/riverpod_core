import 'package:flutter/widgets.dart';

/// Width classes (DESIGN_SYSTEM.md): phone < 600, tablet 600-1023,
/// desktop >= 1024 dp.
enum AppBreakpoint { phone, tablet, desktop }

const double tabletMinWidth = 600;
const double desktopMinWidth = 1024;

/// Content max width on large screens for forms and lists.
const double maxContentWidth = 720;

AppBreakpoint breakpointForWidth(double width) {
  if (width >= desktopMinWidth) return AppBreakpoint.desktop;
  if (width >= tabletMinWidth) return AppBreakpoint.tablet;
  return AppBreakpoint.phone;
}

extension AppBreakpointContext on BuildContext {
  /// Width class of the current window (not the device).
  AppBreakpoint get breakpoint =>
      breakpointForWidth(MediaQuery.sizeOf(this).width);

  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;
}

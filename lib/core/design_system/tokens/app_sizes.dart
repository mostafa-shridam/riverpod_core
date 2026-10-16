import 'package:flutter/foundation.dart';

/// Component sizes shared by design_system widgets. Values in logical pixels.
@immutable
class AppSizes {
  const AppSizes({
    this.minTouchTarget = 48.0,
    this.buttonHeightSm = 40.0,
    this.buttonHeightMd = 48.0,
    this.buttonHeightLg = 56.0,
    this.iconSm = 18.0,
    this.iconMd = 20.0,
    this.iconLg = 24.0,
    this.spinnerStroke = 2.0,
    this.outlineWidth = 1.0,
    this.focusedOutlineWidth = 2.0,
    this.otpBoxWidth = 48.0,
    this.otpBoxHeight = 56.0,
  });

  static const AppSizes standard = AppSizes();

  /// Smallest tap target for any interactive widget.
  final double minTouchTarget;
  final double buttonHeightSm;
  final double buttonHeightMd;
  final double buttonHeightLg;
  final double iconSm;
  final double iconMd;
  final double iconLg;
  final double spinnerStroke;
  final double outlineWidth;
  final double focusedOutlineWidth;
  final double otpBoxWidth;
  final double otpBoxHeight;
}

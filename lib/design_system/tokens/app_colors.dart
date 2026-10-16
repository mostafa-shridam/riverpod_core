import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Semantic colors that M3 has no role for (success, warning, info), each
/// with an `on*` color and a container color. Error, primary, secondary and
/// surface roles come from the M3 `ColorScheme` built from [brandSeedColor].
@immutable
class AppSemanticColors {
  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
  });

  /// Light scheme. Accents are dark enough to hold 4.5:1 against white text.
  static const AppSemanticColors light = AppSemanticColors(
    success: Color(0xFF1B6D2F),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFB7F2BE),
    onSuccessContainer: Color(0xFF00210A),
    warning: Color(0xFF7A5200),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFFDEA6),
    onWarningContainer: Color(0xFF281800),
    info: Color(0xFF1D5FAD),
    onInfo: Color(0xFFFFFFFF),
    infoContainer: Color(0xFFD6E3FF),
    onInfoContainer: Color(0xFF001B3F),
  );

  /// Dark scheme. Accents are light tones so they read on dark surfaces.
  static const AppSemanticColors dark = AppSemanticColors(
    success: Color(0xFF9AD8A0),
    onSuccess: Color(0xFF003914),
    successContainer: Color(0xFF0F5226),
    onSuccessContainer: Color(0xFFB7F2BE),
    warning: Color(0xFFF0BE5F),
    onWarning: Color(0xFF432C00),
    warningContainer: Color(0xFF5E4100),
    onWarningContainer: Color(0xFFFFDEA6),
    info: Color(0xFFA8C8FF),
    onInfo: Color(0xFF00305F),
    infoContainer: Color(0xFF154785),
    onInfoContainer: Color(0xFFD6E3FF),
  );

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;
}

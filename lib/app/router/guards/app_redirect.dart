import 'package:riverpod_core/app/router/paths.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';

/// Redirect rules, pure so they can be tested without a router.
///
/// Order: startup (splash) until the session and onboarding state are known;
/// then onboarding until seen; then sign-in until signed in; then the app.
/// Returns the location to go to instead, or null to stay.
String? appRedirect({
  required String location,
  required SessionStatus session,
  required bool? onboardingSeen,
}) {
  final target = location == '/' ? AppPaths.home : location;

  if (session == SessionStatus.unknown || onboardingSeen == null) {
    return target == AppPaths.splash ? null : AppPaths.splash;
  }

  final bool allowed;
  final String destination;
  if (!onboardingSeen) {
    allowed = target == AppPaths.onboarding;
    destination = AppPaths.onboarding;
  } else if (session == SessionStatus.signedOut) {
    allowed = target == AppPaths.login;
    destination = AppPaths.login;
  } else {
    allowed = !const {
      AppPaths.splash,
      AppPaths.onboarding,
      AppPaths.login,
    }.contains(target);
    destination = AppPaths.home;
  }

  if (allowed) return target == location ? null : target;
  return destination;
}

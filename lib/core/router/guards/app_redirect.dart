import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/startup/splash_page.dart';
import 'package:riverpod_core/features/auth/presentation/pages/login_page.dart';
import 'package:riverpod_core/features/home/presentation/pages/home_page.dart';
import 'package:riverpod_core/features/onboarding/presentation/pages/onboarding_page.dart';

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
  final target = location == '/' ? HomePage.routeName : location;

  if (session == SessionStatus.unknown || onboardingSeen == null) {
    return target == SplashPage.routeName ? null : SplashPage.routeName;
  }

  final bool allowed;
  final String destination;
  if (!onboardingSeen) {
    allowed = target == OnboardingPage.routeName;
    destination = OnboardingPage.routeName;
  } else if (session == SessionStatus.signedOut) {
    allowed = target == LoginPage.routeName;
    destination = LoginPage.routeName;
  } else {
    allowed = !const {
      SplashPage.routeName,
      OnboardingPage.routeName,
      LoginPage.routeName,
    }.contains(target);
    destination = HomePage.routeName;
  }

  if (allowed) return target == location ? null : target;
  return destination;
}

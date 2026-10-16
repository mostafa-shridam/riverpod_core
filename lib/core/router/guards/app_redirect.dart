import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/remote_config/app_gate.dart';
import 'package:riverpod_core/core/startup/splash_page.dart';
import 'package:riverpod_core/features/app_gate/presentation/pages/force_update_page.dart';
import 'package:riverpod_core/features/app_gate/presentation/pages/maintenance_page.dart';
import 'package:riverpod_core/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:riverpod_core/features/auth/presentation/pages/login_page.dart';
import 'package:riverpod_core/features/auth/presentation/pages/register_page.dart';
import 'package:riverpod_core/features/home/presentation/pages/home_page.dart';
import 'package:riverpod_core/features/onboarding/presentation/pages/onboarding_page.dart';

/// Redirect rules, pure so they can be tested without a router.
///
/// Order: startup (splash) until the startup sequence is done and the session
/// and onboarding state are known; then onboarding until seen; then sign-in
/// until signed in; then the app. Returns the location to go to instead, or
/// null to stay.
String? appRedirect({
  required String location,
  required SessionStatus session,
  required bool? onboardingSeen,
  bool startupReady = true,
  AppGateStatus gate = AppGateStatus.ok,
}) {
  final target = location == '/' ? HomePage.routeName : location;

  if (!startupReady ||
      session == SessionStatus.unknown ||
      onboardingSeen == null) {
    return target == SplashPage.routeName ? null : SplashPage.routeName;
  }

  // The gate wins over onboarding and sign-in: maintenance and forced updates
  // block everything until the server (or the store) resolves them.
  final gateRoute = switch (gate) {
    AppGateStatus.maintenance => MaintenancePage.routeName,
    AppGateStatus.updateRequired => ForceUpdatePage.routeName,
    AppGateStatus.ok || AppGateStatus.updateAvailable => null,
  };
  if (gateRoute != null) {
    return location == gateRoute ? null : gateRoute;
  }

  final bool allowed;
  final String destination;
  if (!onboardingSeen) {
    allowed = target == OnboardingPage.routeName;
    destination = OnboardingPage.routeName;
  } else if (session == SessionStatus.signedOut) {
    allowed = const {
      LoginPage.routeName,
      RegisterPage.routeName,
      ForgotPasswordPage.routeName,
    }.contains(target);
    destination = LoginPage.routeName;
  } else {
    allowed = !const {
      SplashPage.routeName,
      OnboardingPage.routeName,
      LoginPage.routeName,
      RegisterPage.routeName,
      ForgotPasswordPage.routeName,
      ForceUpdatePage.routeName,
      MaintenancePage.routeName,
    }.contains(target);
    destination = HomePage.routeName;
  }

  if (allowed) return target == location ? null : target;
  return destination;
}

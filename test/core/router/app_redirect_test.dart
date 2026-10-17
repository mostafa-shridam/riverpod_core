import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/remote_config/app_gate.dart';
import 'package:riverpod_core/core/router/guards/app_redirect.dart';
import 'package:riverpod_core/core/startup/splash_page.dart';
import 'package:riverpod_core/features/app_gate/presentation/pages/force_update_page.dart';
import 'package:riverpod_core/features/app_gate/presentation/pages/maintenance_page.dart';
import 'package:riverpod_core/features/auth/presentation/pages/login_page.dart';
import 'package:riverpod_core/features/home/presentation/pages/home_page.dart';
import 'package:riverpod_core/features/more/presentation/pages/more_page.dart';
import 'package:riverpod_core/features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  String? redirect(
    String location, {
    required SessionStatus session,
    required bool? onboardingSeen,
  }) {
    return appRedirect(
      location: location,
      session: session,
      onboardingSeen: onboardingSeen,
    );
  }

  group('startup', () {
    test('stays on splash while session or onboarding is unknown', () {
      expect(
        redirect(
          HomePage.routeName,
          session: SessionStatus.unknown,
          onboardingSeen: true,
        ),
        SplashPage.routeName,
      );
      expect(
        redirect(
          SplashPage.routeName,
          session: SessionStatus.signedIn,
          onboardingSeen: null,
        ),
        isNull,
      );
    });
  });

  group('onboarding', () {
    test('an unseen onboarding sends every location to onboarding', () {
      for (final location in [
        HomePage.routeName,
        LoginPage.routeName,
        MorePage.routeName,
      ]) {
        expect(
          redirect(
            location,
            session: SessionStatus.signedOut,
            onboardingSeen: false,
          ),
          OnboardingPage.routeName,
          reason: location,
        );
      }
    });

    test('onboarding itself is allowed until seen', () {
      expect(
        redirect(
          OnboardingPage.routeName,
          session: SessionStatus.signedOut,
          onboardingSeen: false,
        ),
        isNull,
      );
    });
  });

  group('session', () {
    test('signed out goes to login from the app', () {
      expect(
        redirect(
          HomePage.routeName,
          session: SessionStatus.signedOut,
          onboardingSeen: true,
        ),
        LoginPage.routeName,
      );
    });

    test('signed out may stay on login', () {
      expect(
        redirect(
          LoginPage.routeName,
          session: SessionStatus.signedOut,
          onboardingSeen: true,
        ),
        isNull,
      );
    });

    test('signed in leaves login and splash for home', () {
      for (final location in [LoginPage.routeName, SplashPage.routeName]) {
        expect(
          redirect(
            location,
            session: SessionStatus.signedIn,
            onboardingSeen: true,
          ),
          HomePage.routeName,
          reason: location,
        );
      }
    });

    test('signed in may open any app location', () {
      for (final location in [
        HomePage.routeName,
        MorePage.routeName,
        '/items/1',
      ]) {
        expect(
          redirect(
            location,
            session: SessionStatus.signedIn,
            onboardingSeen: true,
          ),
          isNull,
          reason: location,
        );
      }
    });

    test('root redirects to home', () {
      expect(
        redirect('/', session: SessionStatus.signedIn, onboardingSeen: true),
        HomePage.routeName,
      );
    });
  });
  group('startup readiness', () {
    test('stays on splash until the startup sequence is done', () {
      expect(
        appRedirect(
          location: HomePage.routeName,
          session: SessionStatus.signedIn,
          onboardingSeen: true,
          startupReady: false,
        ),
        SplashPage.routeName,
      );
    });

    test('splash stays put while the startup sequence runs', () {
      expect(
        appRedirect(
          location: SplashPage.routeName,
          session: SessionStatus.signedOut,
          onboardingSeen: true,
          startupReady: false,
        ),
        isNull,
      );
    });

    test('once ready, the normal rules apply again', () {
      expect(
        appRedirect(
          location: HomePage.routeName,
          session: SessionStatus.signedOut,
          onboardingSeen: true,
          startupReady: true,
        ),
        LoginPage.routeName,
      );
    });
  });
  group('app gate', () {
    test('maintenance sends every location to the maintenance page', () {
      for (final location in [
        HomePage.routeName,
        LoginPage.routeName,
        OnboardingPage.routeName,
      ]) {
        expect(
          appRedirect(
            location: location,
            session: SessionStatus.signedIn,
            onboardingSeen: true,
            gate: AppGateStatus.maintenance,
          ),
          MaintenancePage.routeName,
          reason: location,
        );
      }
    });

    test('a forced update wins over sign-in and onboarding', () {
      expect(
        appRedirect(
          location: HomePage.routeName,
          session: SessionStatus.signedOut,
          onboardingSeen: false,
          gate: AppGateStatus.updateRequired,
        ),
        ForceUpdatePage.routeName,
      );
    });

    test('the gate page stays put while the gate holds', () {
      expect(
        appRedirect(
          location: ForceUpdatePage.routeName,
          session: SessionStatus.signedIn,
          onboardingSeen: true,
          gate: AppGateStatus.updateRequired,
        ),
        isNull,
      );
      expect(
        appRedirect(
          location: MaintenancePage.routeName,
          session: SessionStatus.signedIn,
          onboardingSeen: true,
          gate: AppGateStatus.maintenance,
        ),
        isNull,
      );
    });

    test('once the gate is ok, a gate page leads back into the app', () {
      expect(
        appRedirect(
          location: ForceUpdatePage.routeName,
          session: SessionStatus.signedIn,
          onboardingSeen: true,
        ),
        HomePage.routeName,
      );
      expect(
        appRedirect(
          location: MaintenancePage.routeName,
          session: SessionStatus.signedOut,
          onboardingSeen: true,
        ),
        LoginPage.routeName,
      );
    });

    test('a soft update does not redirect', () {
      expect(
        appRedirect(
          location: HomePage.routeName,
          session: SessionStatus.signedIn,
          onboardingSeen: true,
          gate: AppGateStatus.updateAvailable,
        ),
        isNull,
      );
    });

    test('the gate waits for startup', () {
      expect(
        appRedirect(
          location: HomePage.routeName,
          session: SessionStatus.signedIn,
          onboardingSeen: true,
          startupReady: false,
          gate: AppGateStatus.maintenance,
        ),
        SplashPage.routeName,
      );
    });
  });
}

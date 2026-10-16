import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/app/router/guards/app_redirect.dart';
import 'package:riverpod_core/app/router/placeholder_pages.dart';
import 'package:riverpod_core/app/startup/splash_page.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/features/home/presentation/pages/home_page.dart';

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
}

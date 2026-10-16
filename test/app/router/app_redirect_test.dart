import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/app/router/guards/app_redirect.dart';
import 'package:riverpod_core/app/router/paths.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';

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
          AppPaths.home,
          session: SessionStatus.unknown,
          onboardingSeen: true,
        ),
        AppPaths.splash,
      );
      expect(
        redirect(
          AppPaths.splash,
          session: SessionStatus.signedIn,
          onboardingSeen: null,
        ),
        isNull,
      );
    });
  });

  group('onboarding', () {
    test('an unseen onboarding sends every location to onboarding', () {
      for (final location in [AppPaths.home, AppPaths.login, AppPaths.more]) {
        expect(
          redirect(
            location,
            session: SessionStatus.signedOut,
            onboardingSeen: false,
          ),
          AppPaths.onboarding,
          reason: location,
        );
      }
    });

    test('onboarding itself is allowed until seen', () {
      expect(
        redirect(
          AppPaths.onboarding,
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
          AppPaths.home,
          session: SessionStatus.signedOut,
          onboardingSeen: true,
        ),
        AppPaths.login,
      );
    });

    test('signed out may stay on login', () {
      expect(
        redirect(
          AppPaths.login,
          session: SessionStatus.signedOut,
          onboardingSeen: true,
        ),
        isNull,
      );
    });

    test('signed in leaves login and splash for home', () {
      for (final location in [AppPaths.login, AppPaths.splash]) {
        expect(
          redirect(
            location,
            session: SessionStatus.signedIn,
            onboardingSeen: true,
          ),
          AppPaths.home,
          reason: location,
        );
      }
    });

    test('signed in may open any app location', () {
      for (final location in [AppPaths.home, AppPaths.more, '/items/1']) {
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
        AppPaths.home,
      );
    });
  });
}

/// Every route path of the app. Typed routes use these in their annotations,
/// and redirect rules compare against them.
abstract final class AppPaths {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const home = '/home';
  static const more = '/more';
  static const itemPrefix = '/items';
}

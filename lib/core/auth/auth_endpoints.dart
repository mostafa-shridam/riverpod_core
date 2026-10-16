/// Auth endpoints, in ONE place. Paths are relative to `AppConfig.apiBaseUrl`.
///
/// These are the defaults the app assumes. Change them here when the backend
/// differs; nothing else hard-codes an auth path.
abstract final class AuthEndpoints {
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';
  static const forgotPassword = '/auth/forgot-password';
}

/// Runs the auth feature against an in-memory source (no backend needed).
/// Set to false once [AuthEndpoints] exist on the server.
const bool authUseMockSource = true;

import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Key of the generic "try again" action label.
const String errorRetryKey = LocaleKeys.errors_retry;

/// `errors.*` localization key describing [exception] to the user. The
/// switch is exhaustive: a new exception type will not compile until mapped.
String errorMessageKey(AppException exception) => switch (exception) {
  NetworkException() => LocaleKeys.errors_network,
  RequestTimeoutException() => LocaleKeys.errors_timeout,
  UnauthorizedException() => LocaleKeys.errors_unauthorized,
  ForbiddenException() => LocaleKeys.errors_forbidden,
  NotFoundException() => LocaleKeys.errors_notFound,
  ValidationException() => LocaleKeys.errors_validation,
  ServerException() => LocaleKeys.errors_server,
  CancelledException() => LocaleKeys.errors_cancelled,
  UnknownException() => LocaleKeys.errors_unknown,
};

/// Server-provided text that the parser marked user-safe (validation and
/// server errors only), or null. Prefer it over [errorMessageKey] when set.
String? errorServerMessage(AppException exception) => switch (exception) {
  ValidationException(:final userMessage) => userMessage,
  ServerException(:final userMessage) => userMessage,
  _ => null,
};

/// Unified error type thrown by repositories and held in `AsyncError`.
///
/// [message] is for logs and developers only; users see localized text from
/// `error_messages.dart`.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause, this.stackTrace});

  /// Developer-facing description (never shown to users).
  final String message;

  /// The original error this exception was mapped from, if any.
  final Object? cause;

  /// Stack trace of [cause], if any.
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

/// No connectivity (connection error, socket failure).
final class NetworkException extends AppException {
  const NetworkException({
    String message = 'No network connection',
    super.cause,
    super.stackTrace,
  }) : super(message);
}

/// Connect, send or receive timeout.
final class RequestTimeoutException extends AppException {
  const RequestTimeoutException({
    String message = 'Request timed out',
    super.cause,
    super.stackTrace,
  }) : super(message);
}

/// HTTP 401.
final class UnauthorizedException extends AppException {
  const UnauthorizedException({
    String message = 'Unauthorized',
    super.cause,
    super.stackTrace,
  }) : super(message);
}

/// HTTP 403.
final class ForbiddenException extends AppException {
  const ForbiddenException({
    String message = 'Forbidden',
    super.cause,
    super.stackTrace,
  }) : super(message);
}

/// HTTP 404.
final class NotFoundException extends AppException {
  const NotFoundException({
    String message = 'Not found',
    super.cause,
    super.stackTrace,
  }) : super(message);
}

/// HTTP 400/409/422 carrying per-field errors.
final class ValidationException extends AppException {
  const ValidationException({
    this.fieldErrors = const {},
    this.userMessage,
    String message = 'Validation failed',
    super.cause,
    super.stackTrace,
  }) : super(message);

  /// Field name to its error messages, as sent by the server.
  final Map<String, List<String>> fieldErrors;

  /// Server message the parser marked as safe to show; otherwise null.
  final String? userMessage;

  /// First error message for [field], or null when there is none.
  String? firstMessageFor(String field) {
    final messages = fieldErrors[field];
    if (messages == null || messages.isEmpty) return null;
    return messages.first;
  }
}

/// HTTP 5xx.
final class ServerException extends AppException {
  const ServerException({
    required this.statusCode,
    this.userMessage,
    String message = 'Server error',
    super.cause,
    super.stackTrace,
  }) : super(message);

  final int statusCode;

  /// Server message the parser marked as safe to show; otherwise null.
  final String? userMessage;
}

/// The request was cancelled by the caller; never shown to the user.
final class CancelledException extends AppException {
  const CancelledException({
    String message = 'Request cancelled',
    super.cause,
    super.stackTrace,
  }) : super(message);
}

/// Anything that does not match another case.
final class UnknownException extends AppException {
  const UnknownException({
    String message = 'Unknown error',
    super.cause,
    super.stackTrace,
  }) : super(message);
}

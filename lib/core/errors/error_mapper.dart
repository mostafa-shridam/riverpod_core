import 'dart:async' as async;
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';

/// What an [ErrorBodyParser] extracted from a server error body.
class ParsedErrorBody {
  const ParsedErrorBody({
    this.message,
    this.fieldErrors = const {},
    this.messageIsUserSafe = false,
  });

  /// Server-provided message, if any.
  final String? message;

  /// Field name to messages; empty when the body has none.
  final Map<String, List<String>> fieldErrors;

  /// True only when [message] may be shown to the user as is.
  final bool messageIsUserSafe;
}

/// The ONE place that knows the server error body shape. Replace it (pass a
/// different parser to [mapError]) when an API uses another shape.
abstract interface class ErrorBodyParser {
  ParsedErrorBody parse(Object? data);
}

/// Understands `{message, errors: {field: [..]}}` (a JSON string or a decoded
/// map). Anything else yields an empty result, never an exception.
///
/// The server message is NOT marked user-safe unless [trustServerMessage] is
/// set, because a backend may leak internals in it.
class DefaultErrorBodyParser implements ErrorBodyParser {
  const DefaultErrorBodyParser({this.trustServerMessage = false});

  final bool trustServerMessage;

  @override
  ParsedErrorBody parse(Object? data) {
    final body = _asMap(data);
    if (body == null) return const ParsedErrorBody();

    final rawMessage = body['message'];
    final message = rawMessage is String && rawMessage.trim().isNotEmpty
        ? rawMessage.trim()
        : null;

    final fieldErrors = <String, List<String>>{};
    final rawErrors = body['errors'];
    if (rawErrors is Map) {
      rawErrors.forEach((field, value) {
        final messages = switch (value) {
          final String s => [s],
          final List<dynamic> l => [
            for (final item in l)
              if (item is String && item.isNotEmpty) item,
          ],
          _ => <String>[],
        };
        if (messages.isNotEmpty) fieldErrors['$field'] = messages;
      });
    }

    return ParsedErrorBody(
      message: message,
      fieldErrors: fieldErrors,
      messageIsUserSafe: trustServerMessage && message != null,
    );
  }

  Map<dynamic, dynamic>? _asMap(Object? data) {
    if (data is Map) return data;
    if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        return decoded is Map ? decoded : null;
      } on FormatException {
        return null;
      }
    }
    return null;
  }
}

/// Maps any thrown [error] to an [AppException] (NETWORKING.md table). This is
/// the only place HTTP codes and transport errors are inspected.
AppException mapError(
  Object error,
  StackTrace stack, {
  ErrorBodyParser parser = const DefaultErrorBodyParser(),
}) {
  if (error is AppException) return error;
  if (error is DioException) return _mapDio(error, stack, parser);
  if (error is SocketException) {
    return NetworkException(cause: error, stackTrace: stack);
  }
  if (error is async.TimeoutException) {
    return RequestTimeoutException(cause: error, stackTrace: stack);
  }
  return UnknownException(
    message: error.toString(),
    cause: error,
    stackTrace: stack,
  );
}

AppException _mapDio(DioException e, StackTrace stack, ErrorBodyParser parser) {
  // The error interceptor may already have mapped it.
  final nested = e.error;
  if (nested is AppException) return nested;

  final trace = e.stackTrace == StackTrace.empty ? stack : e.stackTrace;
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return RequestTimeoutException(cause: e, stackTrace: trace);
    case DioExceptionType.cancel:
      return CancelledException(cause: e, stackTrace: trace);
    case DioExceptionType.connectionError:
      return NetworkException(cause: e, stackTrace: trace);
    case DioExceptionType.badResponse:
      return _mapStatus(e, trace, parser);
    case DioExceptionType.badCertificate:
      return UnknownException(
        message: 'Bad certificate',
        cause: e,
        stackTrace: trace,
      );
    case DioExceptionType.unknown:
      if (nested is SocketException) {
        return NetworkException(cause: e, stackTrace: trace);
      }
      if (nested is async.TimeoutException) {
        return RequestTimeoutException(cause: e, stackTrace: trace);
      }
      return UnknownException(
        message: e.message ?? 'Unknown network error',
        cause: e,
        stackTrace: trace,
      );
  }
}

AppException _mapStatus(
  DioException e,
  StackTrace trace,
  ErrorBodyParser parser,
) {
  final status = e.response?.statusCode;
  switch (status) {
    case 401:
      return UnauthorizedException(cause: e, stackTrace: trace);
    case 403:
      return ForbiddenException(cause: e, stackTrace: trace);
    case 404:
      return NotFoundException(cause: e, stackTrace: trace);
    case 400 || 409 || 422:
      final body = parser.parse(e.response?.data);
      // 400/409/422 are validation failures even when the body carries no
      // per-field messages: showing "validation" beats "unknown error".
      return ValidationException(
        fieldErrors: body.fieldErrors,
        userMessage: body.messageIsUserSafe ? body.message : null,
        cause: e,
        stackTrace: trace,
      );
    case final int code when code >= 500 && code < 600:
      final body = parser.parse(e.response?.data);
      return ServerException(
        statusCode: code,
        userMessage: body.messageIsUserSafe ? body.message : null,
        cause: e,
        stackTrace: trace,
      );
    default:
      return UnknownException(
        message: 'HTTP $status',
        cause: e,
        stackTrace: trace,
      );
  }
}

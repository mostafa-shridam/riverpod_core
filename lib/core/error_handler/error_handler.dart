import 'package:riverpod_core/core/remote_services/api_exceptions.dart';

class ErrorHandler {
  static String getErrorMessage(Exception exception) {
    if (exception is ServerException) {
      return exception.message;
    } else if (exception is NetworkException) {
      return exception.message;
    } else if (exception is UnauthorizedException) {
      return exception.message;
    } else if (exception is BadRequestException) {
      return exception.message;
    } else if (exception is UnknownException) {
      return exception.message;
    } else {
      return 'Unknown error';
    }
  }
}

import 'package:dio/dio.dart';
import 'package:riverpod_core/core/errors/error_mapper.dart';

/// Last interceptor. Maps the error once with [mapError] and rethrows a
/// `DioException` whose `error` is the `AppException`, so repositories read
/// `e.error`. Nothing here inspects HTTP codes: that stays in `error_mapper`.
class ErrorMappingInterceptor extends Interceptor {
  const ErrorMappingInterceptor({this.parser = const DefaultErrorBodyParser()});

  final ErrorBodyParser parser;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final mapped = mapError(err, err.stackTrace, parser: parser);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: mapped,
        message: err.message,
        stackTrace: err.stackTrace,
      ),
    );
  }
}

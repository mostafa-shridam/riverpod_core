import 'package:dio/dio.dart';
import 'package:riverpod_core/core/remote_services/api_exceptions.dart';
import 'package:riverpod_core/core/remote_services/api_result.dart';
import 'package:riverpod_core/core/remote_services/dio_client.dart';

// Base API Service class that uses DioClient
// It provides helper methods to make requests and handle errors centrally (simple mapping).
// More complex error handling should be done in error_handler.dart or repository layer.
class ApiService {
  final Dio _dio;

  ApiService(DioClient dioClient) : _dio = dioClient.dio;

  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(dynamic data) fromJson,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return Success(fromJson(response.data));
    } on DioException catch (e) {
      return Failure(_handleDioException(e));
    } catch (e) {
      return Failure(UnknownException(message: e.toString()));
    }
  }

  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(dynamic data) fromJson,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return Success(fromJson(response.data));
    } on DioException catch (e) {
      return Failure(_handleDioException(e));
    } catch (e) {
      return Failure(UnknownException(message: e.toString()));
    }
  }

  // Helper to map DioException to custom ApiException
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(message: 'Connection timed out');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return UnauthorizedException(
            message: 'Unauthorized',
            statusCode: statusCode,
          );
        } else if (statusCode == 400) {
          return BadRequestException(
            message: 'Bad Request',
            statusCode: statusCode,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(
            message: 'Server Error',
            statusCode: statusCode,
          );
        }
        return UnknownException(
          message: 'Received invalid status code: $statusCode',
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return UnknownException(message: 'Request cancelled');
      default:
        return NetworkException(message: 'Network error occurred');
    }
  }
}

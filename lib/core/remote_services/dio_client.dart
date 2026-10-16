import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// Base class for configuring Dio with interceptors, logging, and timeouts
class DioClient {
  late final Dio _dio;

  DioClient({required String baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: 30000),
        receiveTimeout: const Duration(milliseconds: 30000),
        sendTimeout: const Duration(milliseconds: 30000),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            log('REQUEST[${options.method}] => PATH: ${options.path}');
            log('Headers: ${options.headers}');
            log('Data: ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            log(
              'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
            );
            log('Data: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            log(
              'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
            );
            log('Message: ${e.message}');
          }
          return handler.next(e);
        },
      ),
    );

    // Add retry interceptor (simplified version for now, prefer using dio_smart_retry/retry package)
    // For a robust implementation, consider adding the `dio_smart_retry` package.
  }

  Dio get dio => _dio;
}

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/errors/error_mapper.dart';

import '../../helpers/fake_http_adapter.dart';

Future<AppException> _fail(
  FakeHttpAdapter adapter, {
  ErrorBodyParser parser = const DefaultErrorBodyParser(),
  CancelToken? cancelToken,
}) async {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
    ..httpClientAdapter = adapter;
  try {
    await dio.get<Object?>('/x', cancelToken: cancelToken);
  } on DioException catch (e, s) {
    return mapError(e, s, parser: parser);
  }
  fail('Expected a DioException');
}

Future<AppException> _status(
  int code, [
  Object? body,
  ErrorBodyParser parser = const DefaultErrorBodyParser(),
]) => _fail(FakeHttpAdapter()..enqueueJson(code, body), parser: parser);

DioException _dio(DioExceptionType type, {Object? error}) => DioException(
  requestOptions: RequestOptions(path: '/x'),
  type: type,
  error: error,
);

void main() {
  group('mapError table', () {
    test('connectionError -> NetworkException', () {
      final e = mapError(
        _dio(DioExceptionType.connectionError),
        StackTrace.current,
      );
      expect(e, isA<NetworkException>());
      expect(e.cause, isA<DioException>());
    });

    test('SocketException -> NetworkException', () {
      expect(
        mapError(const SocketException('x'), StackTrace.current),
        isA<NetworkException>(),
      );
    });

    test('unknown Dio type wrapping SocketException -> NetworkException', () {
      expect(
        mapError(
          _dio(DioExceptionType.unknown, error: const SocketException('x')),
          StackTrace.current,
        ),
        isA<NetworkException>(),
      );
    });

    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      test('$type -> RequestTimeoutException', () {
        expect(
          mapError(_dio(type), StackTrace.current),
          isA<RequestTimeoutException>(),
        );
      });
    }

    test('dart:async TimeoutException -> RequestTimeoutException', () {
      expect(
        mapError(TimeoutException('x'), StackTrace.current),
        isA<RequestTimeoutException>(),
      );
    });

    test('401 -> UnauthorizedException', () async {
      expect(await _status(401), isA<UnauthorizedException>());
    });

    test('403 -> ForbiddenException', () async {
      expect(await _status(403), isA<ForbiddenException>());
    });

    test('404 -> NotFoundException', () async {
      expect(await _status(404), isA<NotFoundException>());
    });

    for (final code in [400, 409, 422]) {
      test('$code with field errors -> ValidationException', () async {
        final e = await _status(code, {
          'message': 'Invalid',
          'errors': {
            'email': ['Taken', 'Bad'],
            'name': 'Required',
          },
        });
        expect(e, isA<ValidationException>());
        final v = e as ValidationException;
        expect(v.fieldErrors['email'], ['Taken', 'Bad']);
        expect(v.firstMessageFor('email'), 'Taken');
        expect(v.firstMessageFor('name'), 'Required');
        expect(v.firstMessageFor('missing'), isNull);
        expect(v.userMessage, isNull, reason: 'not trusted by default');
      });

      test('$code without field errors -> UnknownException', () async {
        expect(await _status(code, {'message': 'x'}), isA<UnknownException>());
      });
    }

    for (final code in [500, 502, 503, 599]) {
      test('$code -> ServerException($code)', () async {
        final e = await _status(code);
        expect(e, isA<ServerException>());
        expect((e as ServerException).statusCode, code);
      });
    }

    test('other status (418) -> UnknownException', () async {
      expect(await _status(418), isA<UnknownException>());
    });

    test('cancel -> CancelledException', () async {
      final token = CancelToken()..cancel();
      final e = await _fail(FakeHttpAdapter(), cancelToken: token);
      expect(e, isA<CancelledException>());
    });

    test('anything else -> UnknownException keeping cause and stack', () {
      final stack = StackTrace.current;
      final cause = StateError('boom');
      final e = mapError(cause, stack);
      expect(e, isA<UnknownException>());
      expect(e.cause, same(cause));
      expect(e.stackTrace, same(stack));
    });

    test('badCertificate -> UnknownException', () {
      expect(
        mapError(_dio(DioExceptionType.badCertificate), StackTrace.current),
        isA<UnknownException>(),
      );
    });

    test('adapter SocketException through Dio -> NetworkException', () async {
      final e = await _fail(
        FakeHttpAdapter()..enqueueError(const SocketException('down')),
      );
      expect(e, isA<NetworkException>());
    });
  });

  group('AppException passthrough', () {
    test('AppException is returned as is', () {
      const original = ForbiddenException();
      expect(mapError(original, StackTrace.current), same(original));
    });

    test('DioException.error that is an AppException is returned as is', () {
      const original = UnauthorizedException(message: 'mapped earlier');
      final e = mapError(
        _dio(DioExceptionType.badResponse, error: original),
        StackTrace.current,
      );
      expect(e, same(original));
    });
  });

  group('DefaultErrorBodyParser', () {
    const parser = DefaultErrorBodyParser();

    test('decoded map', () {
      final r = parser.parse({
        'message': ' Hi ',
        'errors': {
          'a': ['x'],
        },
      });
      expect(r.message, 'Hi');
      expect(r.fieldErrors, {
        'a': ['x'],
      });
      expect(r.messageIsUserSafe, isFalse);
    });

    test('JSON string body', () {
      final r = parser.parse('{"errors":{"a":["x"]}}');
      expect(r.fieldErrors['a'], ['x']);
      expect(r.message, isNull);
    });

    test('missing, garbage and wrong-typed bodies yield empty results', () {
      for (final data in <Object?>[
        null,
        '',
        'not json',
        '[1,2]',
        42,
        <dynamic>[],
        {'message': 5, 'errors': 'nope'},
        {
          'errors': {'a': <dynamic>[], 'b': 3},
        },
      ]) {
        final r = parser.parse(data);
        expect(r.message, isNull, reason: '$data');
        expect(r.fieldErrors, isEmpty, reason: '$data');
      }
    });

    test('trustServerMessage marks the message user-safe', () async {
      const trusting = DefaultErrorBodyParser(trustServerMessage: true);
      final e = await _status(503, {'message': 'Maintenance'}, trusting);
      expect((e as ServerException).userMessage, 'Maintenance');

      final v = await _status(422, {
        'message': 'Bad data',
        'errors': {
          'a': ['x'],
        },
      }, trusting);
      expect((v as ValidationException).userMessage, 'Bad data');
    });

    test('a custom parser replaces the default shape', () async {
      final e = await _status(422, {'detail': 'x'}, const _DetailParser());
      expect(e, isA<ValidationException>());
      expect((e as ValidationException).fieldErrors['detail'], ['x']);
    });
  });
}

class _DetailParser implements ErrorBodyParser {
  const _DetailParser();

  @override
  ParsedErrorBody parse(Object? data) => ParsedErrorBody(
    fieldErrors: {
      'detail': [(data! as Map)['detail'] as String],
    },
  );
}

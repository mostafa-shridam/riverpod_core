import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/errors/error_messages.dart';

const _all = <AppException>[
  NetworkException(),
  RequestTimeoutException(),
  UnauthorizedException(),
  ForbiddenException(),
  NotFoundException(),
  ValidationException(),
  ServerException(statusCode: 500),
  CancelledException(),
  UnknownException(),
];

Object? _lookup(Map<String, dynamic> json, String key) {
  Object? node = json;
  for (final part in key.split('.')) {
    node = (node! as Map<String, dynamic>)[part];
  }
  return node;
}

void main() {
  test('every exception maps to a distinct errors.* key', () {
    final keys = _all.map(errorMessageKey).toList();
    expect(keys.every((k) => k.startsWith('errors.')), isTrue);
    expect(keys.toSet().length, _all.length);
  });

  test('keys match the documented names', () {
    expect(errorMessageKey(const NetworkException()), 'errors.network');
    expect(errorMessageKey(const RequestTimeoutException()), 'errors.timeout');
    expect(
      errorMessageKey(const UnauthorizedException()),
      'errors.unauthorized',
    );
    expect(errorMessageKey(const NotFoundException()), 'errors.notFound');
    expect(errorRetryKey, 'errors.retry');
  });

  test('every errors.* key is non-empty in ar and en', () {
    final keys = [..._all.map(errorMessageKey), errorRetryKey];
    for (final lang in ['ar', 'en']) {
      final json =
          jsonDecode(File('assets/translations/$lang.json').readAsStringSync())
              as Map<String, dynamic>;
      for (final key in keys) {
        final value = _lookup(json, key);
        expect(value, isA<String>(), reason: '$lang:$key');
        expect((value! as String).trim(), isNotEmpty, reason: '$lang:$key');
      }
    }
  });

  test('server message is exposed only when marked user-safe', () {
    expect(errorServerMessage(const ServerException(statusCode: 500)), isNull);
    expect(
      errorServerMessage(
        const ServerException(statusCode: 500, userMessage: 'Down'),
      ),
      'Down',
    );
    expect(
      errorServerMessage(const ValidationException(userMessage: 'Bad')),
      'Bad',
    );
    expect(errorServerMessage(const NetworkException()), isNull);
  });
}

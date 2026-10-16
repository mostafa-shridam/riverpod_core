import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/config/log_level.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';

class _Record {
  const _Record(this.level, this.message, this.error);

  final LogLevel level;
  final String message;
  final Object? error;
}

void main() {
  late List<_Record> records;
  AppLogger make(LogLevel level) => AppLogger(
    level: level,
    sink: (level, message, error, stackTrace) =>
        records.add(_Record(level, message, error)),
  );

  setUp(() => records = []);

  void logAll(AppLogger logger) {
    logger
      ..debug('d')
      ..info('i')
      ..warning('w')
      ..error('e');
  }

  test('level filtering drops records below the minimum', () {
    logAll(make(LogLevel.warning));
    expect(records.map((r) => r.message), ['w', 'e']);
  });

  test('debug level writes everything', () {
    logAll(make(LogLevel.debug));
    expect(records.map((r) => r.level), [
      LogLevel.debug,
      LogLevel.info,
      LogLevel.warning,
      LogLevel.error,
    ]);
  });

  test('off is silent', () {
    logAll(make(LogLevel.off));
    expect(records, isEmpty);
  });

  test('error and stack trace reach the sink', () {
    StackTrace? seen;
    AppLogger(
      level: LogLevel.error,
      sink: (_, _, error, stackTrace) => seen = stackTrace,
    ).error('boom', error: 'x', stackTrace: StackTrace.current);
    expect(seen, isNotNull);
  });

  test('secrets are masked in message and error', () {
    make(LogLevel.debug).info(
      'Authorization: Bearer abc.def.ghi password=hunter2 ok=1',
      error: 'failed {"token": "s3cr3t"}',
    );
    final record = records.single;
    expect(record.message, isNot(contains('abc.def.ghi')));
    expect(record.message, isNot(contains('hunter2')));
    expect(record.message, contains('ok=1'));
    expect('${record.error}', isNot(contains('s3cr3t')));
  });
}

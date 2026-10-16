import 'dart:developer' as developer;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/log_level.dart';

part 'app_logger.g.dart';

/// Receives every record that passed the level filter.
typedef LogSink =
    void Function(
      LogLevel level,
      String message,
      Object? error,
      StackTrace? stackTrace,
    );

/// Leveled logger. Records below [level] are dropped; `LogLevel.off` silences
/// it. Secrets (tokens, passwords, API keys) are masked before output.
class AppLogger {
  const AppLogger({required this.level, LogSink? sink})
    : _sink = sink ?? _developerSink;

  /// Minimum severity written.
  final LogLevel level;
  final LogSink _sink;

  void debug(String message, {Object? error, StackTrace? stackTrace}) =>
      _write(LogLevel.debug, message, error, stackTrace);

  void info(String message, {Object? error, StackTrace? stackTrace}) =>
      _write(LogLevel.info, message, error, stackTrace);

  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      _write(LogLevel.warning, message, error, stackTrace);

  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _write(LogLevel.error, message, error, stackTrace);

  /// True when a record of [severity] would be written.
  bool isEnabled(LogLevel severity) =>
      level != LogLevel.off && severity.index >= level.index;

  void _write(
    LogLevel severity,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    if (!isEnabled(severity)) {
      return;
    }
    _sink(
      severity,
      redact(message),
      error == null ? null : redact('$error'),
      stackTrace,
    );
  }

  static final RegExp _bearer = RegExp(
    r'Bearer\s+[^\s,;]+',
    caseSensitive: false,
  );
  static final RegExp _secretPair = RegExp(
    r'''(authorization|password|passwd|secret|token|api[_-]?key)(["']?\s*[:=]\s*["']?)[^\s,;"'&}]+''',
    caseSensitive: false,
  );

  /// Masks bearer tokens and `key=value` / `"key": "value"` secrets in [text].
  static String redact(String text) => text
      .replaceAll(_bearer, 'Bearer ***')
      .replaceAllMapped(_secretPair, (match) => '${match[1]}${match[2]}***');

  static void _developerSink(
    LogLevel level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    developer.log(
      message,
      name: 'app',
      level: switch (level) {
        LogLevel.debug => 500,
        LogLevel.info => 800,
        LogLevel.warning => 900,
        LogLevel.error || LogLevel.off => 1000,
      },
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// The app logger, leveled by `AppConfig.logLevel`.
@Riverpod(keepAlive: true)
AppLogger logger(Ref ref) =>
    AppLogger(level: ref.watch(appConfigProvider).logLevel);

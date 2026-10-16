import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/config/config_exception.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/config/log_level.dart';

part 'app_config.g.dart';

/// Typed, validated configuration loaded from `--dart-define-from-file` (D-006, D-018).
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.logLevel,
    required this.enableCrashReporting,
    required this.enableAnalytics,
    this.crashDsn,
  });

  /// Reads the compile-time defines. The only place that touches `*.fromEnvironment`.
  /// Values are read as strings so [AppConfig.fromMap] can report every problem at once.
  factory AppConfig.fromEnvironment() => AppConfig.fromMap({
    'FLAVOR': const String.fromEnvironment('FLAVOR'),
    'APP_NAME': const String.fromEnvironment('APP_NAME'),
    'API_BASE_URL': const String.fromEnvironment('API_BASE_URL'),
    'CONNECT_TIMEOUT_MS': const String.fromEnvironment('CONNECT_TIMEOUT_MS'),
    'RECEIVE_TIMEOUT_MS': const String.fromEnvironment('RECEIVE_TIMEOUT_MS'),
    'LOG_LEVEL': const String.fromEnvironment('LOG_LEVEL'),
    'ENABLE_CRASH_REPORTING': const String.fromEnvironment(
      'ENABLE_CRASH_REPORTING',
    ),
    'ENABLE_ANALYTICS': const String.fromEnvironment('ENABLE_ANALYTICS'),
    'CRASH_DSN': const String.fromEnvironment('CRASH_DSN'),
  });

  /// Parses and validates [env]. Empty values count as missing.
  /// Throws [ConfigException] listing every problem found.
  factory AppConfig.fromMap(Map<String, String> env) {
    final problems = <String>[];
    String? value(String key) {
      final raw = env[key]?.trim();
      return (raw == null || raw.isEmpty) ? null : raw;
    }

    final flavor = _parseFlavor(value('FLAVOR'), problems);
    final defaults = _FlavorDefaults.of(flavor ?? Flavor.dev);

    final appName = value('APP_NAME');
    if (appName == null) {
      problems.add('APP_NAME is required (the display name of the app).');
    }

    final apiBaseUrl = _parseApiBaseUrl(
      value('API_BASE_URL'),
      flavor,
      problems,
    );
    final connectTimeout = _parseTimeout(
      'CONNECT_TIMEOUT_MS',
      value('CONNECT_TIMEOUT_MS'),
      problems,
    );
    final receiveTimeout = _parseTimeout(
      'RECEIVE_TIMEOUT_MS',
      value('RECEIVE_TIMEOUT_MS'),
      problems,
    );
    final logLevel =
        _parseLogLevel(value('LOG_LEVEL'), problems) ?? defaults.logLevel;
    final enableCrashReporting =
        _parseBool(
          'ENABLE_CRASH_REPORTING',
          value('ENABLE_CRASH_REPORTING'),
          problems,
        ) ??
        defaults.enableCrashReporting;
    final enableAnalytics =
        _parseBool('ENABLE_ANALYTICS', value('ENABLE_ANALYTICS'), problems) ??
        false;

    if (problems.isNotEmpty) {
      throw ConfigException(problems);
    }
    return AppConfig(
      flavor: flavor!,
      appName: appName!,
      apiBaseUrl: apiBaseUrl!,
      connectTimeout: connectTimeout!,
      receiveTimeout: receiveTimeout!,
      logLevel: logLevel,
      enableCrashReporting: enableCrashReporting,
      enableAnalytics: enableAnalytics,
      crashDsn: value('CRASH_DSN'),
    );
  }

  final Flavor flavor;
  final String appName;

  /// Absolute base URL of the backend. `https` outside [Flavor.dev].
  final String apiBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final LogLevel logLevel;
  final bool enableCrashReporting;
  final bool enableAnalytics;

  /// Optional crash-reporter DSN. Null when the crash vendor is not configured.
  final String? crashDsn;

  /// Throws [ConfigException] when this config was built for a different
  /// [entrypoint] flavor than the one it was loaded for (D-018).
  void ensureFlavor(Flavor entrypoint) {
    if (flavor == entrypoint) {
      return;
    }
    throw ConfigException([
      'FLAVOR is "${flavor.name}" but this entrypoint is '
          '"${entrypoint.name}". Run the entrypoint that matches FLAVOR.',
    ]);
  }

  static Flavor? _parseFlavor(String? raw, List<String> problems) {
    if (raw == null) {
      problems.add('FLAVOR is required (dev, staging or prod).');
      return null;
    }
    final flavor = Flavor.values.asNameMap()[raw];
    if (flavor == null) {
      problems.add('FLAVOR must be one of dev, staging, prod; got "$raw".');
    }
    return flavor;
  }

  static String? _parseApiBaseUrl(
    String? raw,
    Flavor? flavor,
    List<String> problems,
  ) {
    if (raw == null) {
      problems.add('API_BASE_URL is required (absolute URL of the backend).');
      return null;
    }
    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.isAbsolute || uri.host.isEmpty) {
      problems.add('API_BASE_URL must be an absolute URL; got "$raw".');
      return null;
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      problems.add('API_BASE_URL must use http or https; got "$raw".');
      return null;
    }
    final requiresHttps = flavor == Flavor.staging || flavor == Flavor.prod;
    if (requiresHttps && uri.scheme != 'https') {
      problems.add('API_BASE_URL must use https for ${flavor!.name}.');
      return null;
    }
    return raw;
  }

  static Duration? _parseTimeout(
    String key,
    String? raw,
    List<String> problems,
  ) {
    if (raw == null) {
      problems.add('$key is required (positive milliseconds).');
      return null;
    }
    final millis = int.tryParse(raw);
    if (millis == null || millis <= 0) {
      problems.add('$key must be a positive whole number of ms; got "$raw".');
      return null;
    }
    return Duration(milliseconds: millis);
  }

  static LogLevel? _parseLogLevel(String? raw, List<String> problems) {
    if (raw == null) {
      return null;
    }
    final level = LogLevel.values.asNameMap()[raw];
    if (level == null) {
      problems.add(
        'LOG_LEVEL must be one of debug, info, warning, error, off; '
        'got "$raw".',
      );
    }
    return level;
  }

  static bool? _parseBool(String key, String? raw, List<String> problems) {
    if (raw == null) {
      return null;
    }
    if (raw == 'true') {
      return true;
    }
    if (raw == 'false') {
      return false;
    }
    problems.add('$key must be true or false; got "$raw".');
    return null;
  }
}

/// Per-flavor defaults for optional keys (see the C-02 decision in the report).
class _FlavorDefaults {
  const _FlavorDefaults({
    required this.logLevel,
    required this.enableCrashReporting,
  });

  factory _FlavorDefaults.of(Flavor flavor) => switch (flavor) {
    Flavor.dev => const _FlavorDefaults(
      logLevel: LogLevel.debug,
      enableCrashReporting: false,
    ),
    Flavor.staging => const _FlavorDefaults(
      logLevel: LogLevel.info,
      enableCrashReporting: true,
    ),
    Flavor.prod => const _FlavorDefaults(
      logLevel: LogLevel.warning,
      enableCrashReporting: true,
    ),
  };

  final LogLevel logLevel;
  final bool enableCrashReporting;
}

/// The validated [AppConfig]. Overridden in `bootstrap` (C-08) before any read;
/// reading it earlier is a programming error.
@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) {
  throw UnimplementedError(
    'appConfigProvider must be overridden in bootstrap with the validated config.',
  );
}

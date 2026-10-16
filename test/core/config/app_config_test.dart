import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/config_exception.dart';
import 'package:riverpod_core/core/config/env_loader.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/config/log_level.dart';

Map<String, String> _env({String apiBaseUrl = 'https://api.example.com'}) => {
  'APP_NAME': 'Test App',
  'API_BASE_URL': apiBaseUrl,
  'CONNECT_TIMEOUT_MS': '15000',
  'RECEIVE_TIMEOUT_MS': '20000',
};

List<String> _problemsOf(
  Map<String, String> env, [
  Flavor flavor = Flavor.dev,
]) {
  try {
    AppConfig.fromMap(flavor, env);
  } on ConfigException catch (e) {
    return e.problems;
  }
  fail('Expected ConfigException for $env');
}

void main() {
  group('valid configuration', () {
    test('dev loads with dev defaults', () {
      final config = AppConfig.fromMap(Flavor.dev, _env());

      expect(config.flavor, Flavor.dev);
      expect(config.appName, 'Test App');
      expect(config.apiBaseUrl, 'https://api.example.com');
      expect(config.connectTimeout, const Duration(milliseconds: 15000));
      expect(config.receiveTimeout, const Duration(milliseconds: 20000));
      expect(config.logLevel, LogLevel.debug);
      expect(config.enableCrashReporting, isFalse);
      expect(config.enableAnalytics, isFalse);
      expect(config.crashDsn, isNull);
    });

    test('staging defaults: info log level, crash reporting on', () {
      final config = AppConfig.fromMap(
        Flavor.staging,
        _env(apiBaseUrl: 'https://staging.example.com'),
      );

      expect(config.flavor, Flavor.staging);
      expect(config.logLevel, LogLevel.info);
      expect(config.enableCrashReporting, isTrue);
    });

    test('prod defaults: warning log level, crash reporting on', () {
      final config = AppConfig.fromMap(Flavor.prod, _env());

      expect(config.flavor, Flavor.prod);
      expect(config.logLevel, LogLevel.warning);
      expect(config.enableCrashReporting, isTrue);
    });

    test('explicit optional values override the flavor defaults', () {
      final config = AppConfig.fromMap(Flavor.prod, {
        ..._env(),
        'LOG_LEVEL': 'off',
        'ENABLE_CRASH_REPORTING': 'false',
        'ENABLE_ANALYTICS': 'true',
        'CRASH_DSN': 'https://key@sentry.example.com/1',
      });

      expect(config.logLevel, LogLevel.off);
      expect(config.enableCrashReporting, isFalse);
      expect(config.enableAnalytics, isTrue);
      expect(config.crashDsn, 'https://key@sentry.example.com/1');
    });

    test('empty optional CRASH_DSN is treated as not configured', () {
      final config = AppConfig.fromMap(Flavor.dev, {
        ..._env(),
        'CRASH_DSN': '',
      });

      expect(config.crashDsn, isNull);
    });

    test('dev may use http for a local backend', () {
      final config = AppConfig.fromMap(
        Flavor.dev,
        _env(apiBaseUrl: 'http://10.0.2.2:8080'),
      );

      expect(config.apiBaseUrl, 'http://10.0.2.2:8080');
    });

    test('surrounding whitespace is ignored', () {
      final config = AppConfig.fromMap(Flavor.dev, {
        ..._env(),
        'APP_NAME': '  Test App  ',
      });

      expect(config.appName, 'Test App');
    });
  });

  group('missing required keys', () {
    for (final key in const [
      'APP_NAME',
      'API_BASE_URL',
      'CONNECT_TIMEOUT_MS',
      'RECEIVE_TIMEOUT_MS',
    ]) {
      test('$key missing is reported by name', () {
        final env = _env()..remove(key);

        expect(_problemsOf(env), anyElement(contains(key)));
      });

      test('$key empty counts as missing', () {
        final env = {..._env(), key: '   '};

        expect(_problemsOf(env), anyElement(contains(key)));
      });
    }

    test('every problem is listed together, not just the first', () {
      final problems = _problemsOf({});

      expect(problems, hasLength(4));
      expect(
        problems,
        containsAll([
          contains('APP_NAME'),
          contains('API_BASE_URL'),
          contains('CONNECT_TIMEOUT_MS'),
          contains('RECEIVE_TIMEOUT_MS'),
        ]),
      );
    });
  });

  group('invalid values', () {
    test('bad API_BASE_URL values are rejected', () {
      for (final bad in const [
        'not a url',
        'api.example.com',
        'ftp://files.example.com',
      ]) {
        expect(
          _problemsOf(_env(apiBaseUrl: bad)),
          anyElement(contains('API_BASE_URL')),
          reason: bad,
        );
      }
    });

    test('http API_BASE_URL is rejected in staging and prod', () {
      for (final flavor in const [Flavor.staging, Flavor.prod]) {
        expect(
          _problemsOf(_env(apiBaseUrl: 'http://api.example.com'), flavor),
          anyElement(contains('must use https')),
          reason: flavor.name,
        );
      }
    });

    test('non-positive or non-integer timeouts are rejected', () {
      for (final bad in const ['0', '-5', 'abc', '1.5']) {
        expect(
          _problemsOf({..._env(), 'CONNECT_TIMEOUT_MS': bad}),
          anyElement(contains('CONNECT_TIMEOUT_MS must be')),
          reason: bad,
        );
        expect(
          _problemsOf({..._env(), 'RECEIVE_TIMEOUT_MS': bad}),
          anyElement(contains('RECEIVE_TIMEOUT_MS must be')),
          reason: bad,
        );
      }
    });

    test('bool keys accept only the literal true or false', () {
      for (final bad in const ['yes', '1', 'TRUE']) {
        expect(
          _problemsOf({..._env(), 'ENABLE_ANALYTICS': bad}),
          anyElement(contains('ENABLE_ANALYTICS must be true or false')),
          reason: bad,
        );
        expect(
          _problemsOf({..._env(), 'ENABLE_CRASH_REPORTING': bad}),
          anyElement(contains('ENABLE_CRASH_REPORTING must be true or false')),
          reason: bad,
        );
      }
    });

    test('unknown LOG_LEVEL is rejected, case-sensitively', () {
      for (final bad in const ['verbose', 'INFO']) {
        expect(
          _problemsOf({..._env(), 'LOG_LEVEL': bad}),
          anyElement(contains('LOG_LEVEL must be one of')),
          reason: bad,
        );
      }
    });

    test('several bad values are all reported in one exception', () {
      final problems = _problemsOf({
        ..._env(apiBaseUrl: 'http://api.example.com'),
        'CONNECT_TIMEOUT_MS': '0',
        'ENABLE_ANALYTICS': 'maybe',
      }, Flavor.prod);

      expect(problems, hasLength(3));
    });
  });

  group('ConfigException', () {
    test('message lists every problem and names the env file fix', () {
      const exception = ConfigException(['APP_NAME is required.']);

      expect(
        exception.toString(),
        allOf(
          contains('- APP_NAME is required.'),
          contains('env/<flavor>.env.example'),
        ),
      );
    });
  });

  group('Flavor.current', () {
    test('release builds resolve to prod', () {
      expect(Flavor.resolve(isRelease: true), Flavor.prod);
    });

    test('debug and profile builds resolve to dev', () {
      expect(Flavor.resolve(isRelease: false), Flavor.dev);
    });

    test('current is dev under flutter test (not a release build)', () {
      expect(Flavor.current, Flavor.dev);
    });
  });

  group('EnvLoader', () {
    test('asset path is env/<flavor>.env', () {
      expect(EnvLoader.assetPath(Flavor.staging), 'env/staging.env');
    });

    test('parses the env file text into a map', () async {
      final values = await EnvLoader.load(
        Flavor.dev,
        reader: (path) async {
          expect(path, 'env/dev.env');
          return '# comment\nAPP_NAME=Test App\nAPI_BASE_URL=https://a.example.com\n';
        },
      );

      expect(values, {
        'APP_NAME': 'Test App',
        'API_BASE_URL': 'https://a.example.com',
      });
    });

    test('missing file throws ConfigException with the copy hint', () {
      expect(
        EnvLoader.load(
          Flavor.dev,
          reader: (path) async => throw StateError('Unable to load asset'),
        ),
        throwsA(
          isA<ConfigException>().having(
            (e) => e.problems.single,
            'problem',
            allOf(
              contains('env/dev.env is missing'),
              contains('Copy env/dev.env.example to env/dev.env'),
            ),
          ),
        ),
      );
    });

    test('empty file throws ConfigException with the copy hint', () {
      for (final text in const ['', '  \n# only a comment\n']) {
        expect(
          EnvLoader.load(Flavor.prod, reader: (path) async => text),
          throwsA(
            isA<ConfigException>().having(
              (e) => e.problems.single,
              'problem',
              allOf(
                contains('env/prod.env is empty'),
                contains('Copy env/prod.env.example to env/prod.env'),
              ),
            ),
          ),
          reason: text,
        );
      }
    });
  });

  group('appConfigProvider', () {
    test('throws until overridden in bootstrap', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        () => container.read(appConfigProvider),
        // Riverpod wraps the UnimplementedError, so match on its message.
        throwsA(
          isA<Object>().having(
            (e) => e.toString(),
            'message',
            contains('must be overridden in bootstrap'),
          ),
        ),
      );
    });

    test('returns the override when one is provided', () {
      final config = AppConfig.fromMap(Flavor.dev, _env());
      final container = ProviderContainer(
        overrides: [appConfigProvider.overrideWithValue(config)],
      );
      addTearDown(container.dispose);

      expect(container.read(appConfigProvider), same(config));
    });
  });

  group('env/*.env.example', () {
    for (final flavor in Flavor.values) {
      test('${flavor.name} example is a valid config for its flavor', () {
        final file = File('env/${flavor.name}.env.example');
        final env = DotEnv()
          ..loadFromString(envString: file.readAsStringSync());

        final config = AppConfig.fromMap(flavor, env.env);

        expect(config.flavor, flavor);
      });
    }
  });
}

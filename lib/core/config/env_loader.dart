import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_core/core/config/config_exception.dart';
import 'package:riverpod_core/core/config/flavor.dart';

/// Reads the text of a bundled asset. Injectable so tests need no real files.
typedef AssetReader = Future<String> Function(String path);

/// Loads `env/<flavor>.env` (bundled asset) into a map for `AppConfig.fromMap`.
/// The only place that touches `flutter_dotenv` (D-024).
class EnvLoader {
  const EnvLoader._();

  /// Asset path of the env file for [flavor].
  static String assetPath(Flavor flavor) => 'env/${flavor.name}.env';

  /// Returns the key/value pairs of the env file for [flavor].
  /// Throws [ConfigException] when the file is missing or has no values.
  static Future<Map<String, String>> load(
    Flavor flavor, {
    AssetReader? reader,
  }) async {
    final path = assetPath(flavor);
    final hint =
        'Copy $path.example to $path (and fill it in), then restart the app.';

    final String text;
    try {
      text = await (reader ?? rootBundle.loadString)(path);
    } on Object {
      throw ConfigException(['Env file $path is missing. $hint']);
    }

    final dotenv = DotEnv()..loadFromString(envString: text, isOptional: true);
    final values = Map<String, String>.of(dotenv.env);
    if (values.isEmpty) {
      throw ConfigException(['Env file $path is empty. $hint']);
    }
    return values;
  }
}

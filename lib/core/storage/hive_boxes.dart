import 'package:hive_ce/hive_ce.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hive_boxes.g.dart';

/// Names of the two boxes. Opened once in bootstrap (D-034).
abstract final class HiveBoxNames {
  static const settings = 'settings';
  static const cache = 'cache';
}

/// The settings box. Overridden in bootstrap with the opened box.
@Riverpod(keepAlive: true)
Box<dynamic> settingsBox(Ref ref) => throw UnimplementedError(
  'settingsBox must be overridden in bootstrap after Hive opens it.',
);

/// The cache box. Overridden in bootstrap with the opened box.
@Riverpod(keepAlive: true)
Box<Map<dynamic, dynamic>> cacheBox(Ref ref) => throw UnimplementedError(
  'cacheBox must be overridden in bootstrap after Hive opens it.',
);

/// Provider overrides for opened boxes; used by bootstrap and by tests.
List<Override> storageOverrides({
  required Box<dynamic> settings,
  required Box<Map<dynamic, dynamic>> cache,
}) => [
  settingsBoxProvider.overrideWithValue(settings),
  cacheBoxProvider.overrideWithValue(cache),
];

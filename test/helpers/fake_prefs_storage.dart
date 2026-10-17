import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:riverpod_core/core/storage/cache/cache_store.dart';
import 'package:riverpod_core/core/storage/hive_boxes.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

/// The two Hive boxes opened for a test. [path] is the directory they live in.
typedef TestStorage = ({
  Box<dynamic> settings,
  Box<Map<dynamic, dynamic>> cache,
  String path,
});

/// Opens Hive on a fresh temp directory (no platform channel). Without [path]
/// the directory is created and removed after the test; with [path] the same
/// data is reopened, for restart tests, and the caller owns the directory.
/// Closes any boxes already open, so call it once per test and share the
/// result; [fakePrefsStorage] and [fakeCacheStore] each call it.
Future<TestStorage> openTestStorage({String? path}) async {
  await Hive.close();
  final directory = path == null
      ? await Directory.systemTemp.createTemp('hive_test_')
      : Directory(path);
  if (path == null) {
    addTearDown(() async {
      await Hive.close();
      await directory.delete(recursive: true);
    });
  }
  Hive.init(directory.path);
  return (
    settings: await Hive.openBox<dynamic>(HiveBoxNames.settings),
    cache: await Hive.openBox<Map<dynamic, dynamic>>(HiveBoxNames.cache),
    path: directory.path,
  );
}

/// [PrefsStorage] on a fresh settings box seeded with [initial].
Future<PrefsStorage> fakePrefsStorage([
  Map<String, Object> initial = const {},
]) async {
  final storage = await openTestStorage();
  await storage.settings.putAll(initial);
  return PrefsStorage(storage.settings);
}

/// [CacheStore] on a fresh cache box.
Future<CacheStore> fakeCacheStore() async {
  final storage = await openTestStorage();
  return CacheStore(storage.cache);
}

import 'dart:io';
import 'dart:typed_data';

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

/// A fresh temp directory for a file-backed store, removed after the test.
/// Pass it to [openTestStorage] when the test must survive a reopen.
Future<String> testStoragePath() async {
  final directory = await Directory.systemTemp.createTemp('hive_test_');
  addTearDown(() async {
    // Close first: an open box holds lock files inside the directory.
    await Hive.close();
    await directory.delete(recursive: true);
  });
  return directory.path;
}

/// Opens Hive for one test. Without [path] the boxes live in memory (no file
/// I/O, no platform channel) and are closed after the test. With [path] the
/// boxes are file-backed in that directory, so a restart test can reopen them;
/// the caller owns the directory.
/// Within one test, a call without [path] returns the boxes already opened, so
/// [fakePrefsStorage] and [fakeCacheStore] can be combined freely.
Future<TestStorage> openTestStorage({String? path}) async {
  // Without a path, reuse the storage this test already opened, so a helper
  // that opens its own store cannot close the other one's boxes.
  if (path == null && _openedPath != null && _bothBoxesOpen) {
    return (
      settings: Hive.box<dynamic>(HiveBoxNames.settings),
      cache: Hive.box<Map<dynamic, dynamic>>(HiveBoxNames.cache),
      path: _openedPath!,
    );
  }
  await Hive.close();
  if (path == null) {
    // In memory: no file I/O, so the boxes work inside testWidgets' fake clock,
    // where real file writes never complete.
    _openedPath = '';
    addTearDown(() async {
      await Hive.close();
      _openedPath = null;
    });
    return (
      settings: await Hive.openBox<dynamic>(
        HiveBoxNames.settings,
        bytes: Uint8List(0),
      ),
      cache: await Hive.openBox<Map<dynamic, dynamic>>(
        HiveBoxNames.cache,
        bytes: Uint8List(0),
      ),
      path: '',
    );
  }
  Hive.init(path);
  _openedPath = path;
  return (
    settings: await Hive.openBox<dynamic>(HiveBoxNames.settings),
    cache: await Hive.openBox<Map<dynamic, dynamic>>(HiveBoxNames.cache),
    path: path,
  );
}

/// The temp directory of the storage opened for this test, if any.
String? _openedPath;

bool get _bothBoxesOpen =>
    Hive.isBoxOpen(HiveBoxNames.settings) && Hive.isBoxOpen(HiveBoxNames.cache);

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

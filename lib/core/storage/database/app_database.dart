import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_database.g.dart';

/// HTTP/stale-while-revalidate cache. One row per cache key; keys of
/// user-scoped data include the user id, so logout clears them all.
class CacheEntries extends Table {
  TextColumn get key => text()();
  TextColumn get payload => text()();

  /// Milliseconds since epoch (UTC). Integer, so no precision is lost.
  IntColumn get savedAt => integer()();
  TextColumn get etag => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [CacheEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Throw-away database for tests.
  AppDatabase.inMemory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  Future<CacheEntry?> readCache(String key) {
    return (select(
      cacheEntries,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
  }

  /// Inserts or replaces the entry for [key].
  Future<void> writeCache({
    required String key,
    required String payload,
    required DateTime savedAt,
    String? etag,
  }) {
    return into(cacheEntries).insertOnConflictUpdate(
      CacheEntriesCompanion.insert(
        key: key,
        payload: payload,
        savedAt: savedAt.toUtc().millisecondsSinceEpoch,
        etag: Value(etag),
      ),
    );
  }

  Future<int> deleteCache(String key) {
    return (delete(cacheEntries)..where((t) => t.key.equals(key))).go();
  }

  /// Removes entries saved before [cutoff]. Returns how many were removed.
  Future<int> deleteCacheSavedBefore(DateTime cutoff) {
    final limit = cutoff.toUtc().millisecondsSinceEpoch;
    return (delete(
      cacheEntries,
    )..where((t) => t.savedAt.isSmallerThanValue(limit))).go();
  }

  Future<int> clearCache() => delete(cacheEntries).go();
}

/// The one local database, kept alive for the whole session.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase(driftDatabase(name: 'app_db'));
  ref.onDispose(database.close);
  return database;
}

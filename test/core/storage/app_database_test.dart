import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/storage/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.inMemory();
  });

  tearDown(() async {
    await database.close();
  });

  final saved = DateTime.utc(2026, 10, 16, 12);

  test('insert then read returns the same payload and etag', () async {
    await database.writeCache(
      key: 'products',
      payload: '[1,2]',
      savedAt: saved,
      etag: 'W/"abc"',
    );
    final entry = await database.readCache('products');
    expect(entry, isNotNull);
    expect(entry!.payload, '[1,2]');
    expect(entry.etag, 'W/"abc"');
    expect(
      DateTime.fromMillisecondsSinceEpoch(entry.savedAt, isUtc: true),
      saved,
    );
  });

  test('writing the same key replaces the entry', () async {
    await database.writeCache(key: 'k', payload: 'old', savedAt: saved);
    await database.writeCache(key: 'k', payload: 'new', savedAt: saved);
    expect((await database.readCache('k'))!.payload, 'new');
  });

  test('missing key reads as null', () async {
    expect(await database.readCache('nope'), isNull);
  });

  test('deleteCacheSavedBefore expires only older entries', () async {
    await database.writeCache(
      key: 'old',
      payload: '1',
      savedAt: saved.subtract(const Duration(hours: 2)),
    );
    await database.writeCache(key: 'fresh', payload: '2', savedAt: saved);

    final removed = await database.deleteCacheSavedBefore(
      saved.subtract(const Duration(hours: 1)),
    );

    expect(removed, 1);
    expect(await database.readCache('old'), isNull);
    expect(await database.readCache('fresh'), isNotNull);
  });

  test('deleteCache removes one key', () async {
    await database.writeCache(key: 'a', payload: '1', savedAt: saved);
    await database.writeCache(key: 'b', payload: '2', savedAt: saved);
    await database.deleteCache('a');
    expect(await database.readCache('a'), isNull);
    expect(await database.readCache('b'), isNotNull);
  });

  test('clearCache empties the table', () async {
    await database.writeCache(key: 'a', payload: '1', savedAt: saved);
    await database.writeCache(key: 'b', payload: '2', savedAt: saved);
    await database.clearCache();
    expect(await database.readCache('a'), isNull);
    expect(await database.readCache('b'), isNull);
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/storage/cache/cache_policy.dart';
import 'package:riverpod_core/core/storage/cache/cache_prune_scheduler.dart';
import 'package:riverpod_core/core/storage/cache/cache_pruner.dart';
import 'package:riverpod_core/core/storage/cache/cache_store.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

import '../../../helpers/helpers.dart';

void main() {
  late CacheStore store;
  late PrefsStorage prefs;
  late DateTime now;
  late CachePruneScheduler scheduler;

  setUp(() async {
    final storage = await openTestStorage(path: await testStoragePath());
    store = CacheStore(storage.cache);
    prefs = PrefsStorage(storage.settings);
    now = DateTime.utc(2026, 10, 17, 12);
    scheduler = CachePruneScheduler(
      CachePruner(store, clock: () => now),
      Future.value(prefs),
      clock: () => now,
    );
  });

  /// An entry that is expired under the short preset (one-day maxAge).
  Future<void> writeExpired() => store.write(
    key: 'old',
    payload: 'x',
    savedAt: now.subtract(const Duration(days: 2)),
    policy: CachePolicy.short,
  );

  test('the first check prunes when no prune is on record', () async {
    await writeExpired();

    await scheduler.pruneIfDue();

    expect(store.read('old'), isNull);
    expect(prefs.lastCachePrune, now);
  });

  test('a prune less than a day ago is not repeated', () async {
    await prefs.setLastCachePrune(now.subtract(const Duration(hours: 2)));
    await writeExpired();

    await scheduler.pruneIfDue();

    expect(store.read('old'), isNotNull);
    expect(prefs.lastCachePrune, now.subtract(const Duration(hours: 2)));
  });

  test('a prune more than a day ago runs again', () async {
    await prefs.setLastCachePrune(now.subtract(const Duration(days: 2)));
    await writeExpired();

    await scheduler.pruneIfDue();

    expect(store.read('old'), isNull);
    expect(prefs.lastCachePrune, now);
  });

  test('resuming the app triggers the check', () async {
    await prefs.setLastCachePrune(now.subtract(const Duration(days: 2)));
    await writeExpired();

    scheduler.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await scheduler.pruneIfDue();

    expect(store.read('old'), isNull);
  });

  test('other lifecycle states do not prune', () async {
    await writeExpired();

    scheduler.didChangeAppLifecycleState(AppLifecycleState.paused);
    await pumpEventQueue();

    expect(store.read('old'), isNotNull);
  });
}

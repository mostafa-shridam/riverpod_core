# STATE AND DATA (target state)

## Riverpod + codegen
- Packages: `flutter_riverpod`, `riverpod_annotation`, dev: `riverpod_generator`, `build_runner` (D-002; `riverpod_lint` is not used, see D-017).
- Use `@riverpod` only. Generated files sit beside the source (`x.g.dart`) — the custom `build_extensions` redirect to `generated/` folders is removed (D-003).
- Notifier shape:
```dart
@riverpod
class ProductsController extends _$ProductsController {
  @override
  Future<List<Product>> build() => ref.watch(productRepositoryProvider).list();

  Future<void> refresh() async {
    state = const AsyncLoading<List<Product>>(); // keeps the previous value
    state = await AsyncValue.guard(() => ref.read(productRepositoryProvider).list());
  }
}
```
- Mutations: set `state = const AsyncLoading<T>()` → `AsyncValue.guard` → never leave state stuck in loading. Assigning to a notifier's `state` makes riverpod carry the previous value over (`hasValue` stays true, `isReloading` true; a following `AsyncError` also keeps `value`). `copyWithPrevious` is internal (D-031): never call it.
- Side effects (navigation, snackbar) happen in the widget via `ref.listen`, not in the notifier.
- State classes: `freezed` + sealed unions when a notifier has more than one dimension of state (e.g. filters + page); otherwise plain `AsyncValue<T>`.

## AsyncValue handling in UI
- Always render with `AsyncValueView` (DESIGN_SYSTEM.md); never ad-hoc `when(loading: CircularProgressIndicator)`.
- Keep previous data during reload (`skipLoadingOnRefresh`, `isRefreshing`/`isReloading`, `hasValue`) → drives `refreshing`/`stale`, not `loading`.
- `AsyncError` always holds an `AppException`.

## Caching: cache-first (D-038)
Every read feature goes through the ONE helper in `core/storage/cache/` (Hive box):
- `CachedRepositoryHelper.watch<T>(key, fetch, policy, decode, encode)` returns a `Stream<CacheResult<T>>`:
  1. emits the cached value immediately, flagged `isStale` when older than `policy.ttl`;
  2. revalidates in the background (`etag` / `If-None-Match` when supported);
  3. unchanged (304 or same payload hash) → keeps the cache, emits nothing new; changed → writes the cache and emits the fresh value;
  4. failure → keeps serving the cache flagged `stale` + the error (`stale`/`offline` UI states); error only when there is no cache.
- Entries: key, JSON payload, `savedAt`, `lastAccessedAt`, `etag`, `ttl`, `maxAge`. Writes update or invalidate the affected keys.
- Retention: `CachePolicy` presets (`short`/`medium`/`long`/`static`) set ttl and maxAge in days; expired entries are pruned at startup (off the critical path), on resume after 24h, and least-recently-accessed first when the box passes its cap.
- Logout clears the whole cache. Cache keys include the user id for user-scoped data.

## Storage choices
| Data | Store | Rule |
|---|---|---|
| Settings (theme, onboarding seen, flags) | `hive_ce` box | `core/storage/prefs_storage.dart`; typed keys in one file |
| Tokens, refresh token, anything secret | `flutter_secure_storage` | `core/storage/secure_storage.dart`; never in prefs/DB/logs |
| Structured/offline data, HTTP cache | `hive_ce` boxes | D-034; no SQL, no Drift, no shared_preferences |

## Session lifecycle
`SessionController` (keepAlive, `core/auth/`) is the single owner of auth state. Logout = clear secure storage + cache + DB user data
+ prefs that are user-scoped, then `ref.invalidate` the whole provider graph via a root container reset (`ProviderScope` key change).
Router guards watch `SessionController`.

## Serialization
`freezed` + `json_serializable` for DTOs and state classes. DTOs are immutable, have `fromJson`/`toJson`,
`@JsonSerializable(explicitToJson: true)`, and unknown-enum fallbacks (`@JsonKey(unknownEnumValue: ...)`).

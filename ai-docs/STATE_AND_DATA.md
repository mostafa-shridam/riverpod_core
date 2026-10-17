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
- A repository makes one call: `CachedRepositoryHelper.load<T>(key, fetch, decode, encode, policy, fresh)` returns the data as a `Future`. The stream form, `watch<T>`, is what `load` is built on.
  1. Cache-first: the cached value comes back at once, flagged `isStale` when older than `policy.ttl`; the revalidation finishes in the background.
  2. Revalidation sends the stored ETag as `If-None-Match`. A 304 means unchanged.
  3. Unchanged (304, or the same encoded payload) keeps the cache and writes nothing but the retention fields. A stale copy gets one emission that clears its stale flag. Changed → writes the cache and emits the fresh value.
  4. Failure → keeps serving the cache flagged `stale` + the error (`stale`/`offline` UI states); error only when there is no cache.
  5. `fresh: true` (refresh and reload) waits for the network and returns that answer; a failure is raised even when a cached copy exists, so the page shows the error beside the old data.
- Presets (`CachePolicy`, D-038): `short` 5 min fresh / 1 day kept (feeds, remote config), `medium` 1 h / 7 days (the default for lists and details), `long` 1 day / 30 days, `static` 7 days / 90 days. A feature picks a preset; no feature hand-rolls expiry.
- Entries: key, JSON payload, `savedAt` (last validated), `lastAccessedAt`, `etag`, `ttl`, `maxAge`. Writes update or invalidate the affected keys.
- Pruning (`CachePruner`, scheduled by `CachePruneScheduler`): removes entries past their own `maxAge`, then the least recently accessed entries above the cap (500). It runs after the first frame and on resume when the last prune is more than 24 h old.
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

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

## Caching: stale-while-revalidate
Implemented once in `core/storage/cache/`:
- `CachedRepositoryHelper.watch<T>(key, fetch, ttl, decode, encode)` returns a `Stream<CacheResult<T>>`:
  1. emits cached value immediately with `isStale = expired(ttl)` (if any),
  2. fetches in background; on success writes cache and emits fresh value,
  3. on failure emits cached value flagged `stale` + the error (→ `stale`/`offline` UI states), or just the error if no cache.
- Cache entries: key, JSON payload, `savedAt`, optional `etag`. Stored in the local DB (below).
- Logout clears the whole cache. Cache keys include the user id for user-scoped data.

## Storage choices
| Data | Store | Rule |
|---|---|---|
| Settings (theme, locale, onboarding seen, flags) | `shared_preferences` | `core/storage/prefs_storage.dart`; typed keys in one file |
| Tokens, refresh token, anything secret | `flutter_secure_storage` | `core/storage/secure_storage.dart`; never in prefs/DB/logs |
| Structured/offline data, HTTP cache | one local DB | choice recorded in DECISIONS (D-004): Drift (SQLite) |
Hive (current code) is removed by its migration task; no new code may use it.

## Session lifecycle
`SessionController` (keepAlive, `core/auth/`) is the single owner of auth state. Logout = clear secure storage + cache + DB user data
+ prefs that are user-scoped, then `ref.invalidate` the whole provider graph via a root container reset (`ProviderScope` key change).
Router guards watch `SessionController`.

## Serialization
`freezed` + `json_serializable` for DTOs and state classes. DTOs are immutable, have `fromJson`/`toJson`,
`@JsonSerializable(explicitToJson: true)`, and unknown-enum fallbacks (`@JsonKey(unknownEnumValue: ...)`).

# NETWORKING (target state)

Code lives in `lib/core/network/` (`dio_client.dart`, `interceptors/`, `pagination/`, `transfer/`); errors in `lib/core/errors/`. Features never construct `Dio`; they receive it from `dioProvider`.

## Client
- One `Dio` built by `dioProvider` (keepAlive). Base URL, timeouts and log level come from `AppConfig` — nothing hard-coded.
- Defaults: connect 15 s, send 30 s, receive 30 s (config can override). JSON in/out. `validateStatus` left default so non-2xx surface as `DioException` and are mapped once.
- A second `Dio` without the auth interceptor (`refreshDioProvider`) is used only for the refresh-token call, to avoid recursion.

## Interceptors (order matters)
1. **Idempotency**: for POST/PUT/PATCH/DELETE add `Idempotency-Key: <uuid v4>` unless the caller set one. The same key is reused across retries of one logical request.
2. **Auth**: attach `Authorization: Bearer <access>` from secure storage; skip when `extra['skipAuth'] == true`.
3. **Refresh**: on 401 (not from the refresh call) → single-flight refresh; concurrent requests wait in a queue; on success replay all with the new token; on refresh failure clear session and emit "session expired" (router guard sends the user to auth). Refresh logic is a plain class with an interface so it is unit-testable.
4. **Retry with backoff**: only idempotent methods (GET/HEAD/PUT/DELETE, and writes that carry an idempotency key) on transient errors (connection error, timeouts, 502/503/504, 429 honoring `Retry-After`). Max 3 attempts, exponential backoff 500 ms × 2^n + jitter. Never retry 4xx other than 429.
5. **Logging** (dev flavor only; silent in prod): method, path, status, duration. NEVER log headers or bodies that may contain `Authorization`, tokens, passwords. Redact by allow-list, not by deny-list.
6. **Error mapping**: converts `DioException` → `AppException` and rethrows as `DioException(error: appException)` so repositories read `e.error`.

## Errors
Unified `AppException` (`core/errors/`, see ARCHITECTURE.md); mapping lives ONLY in `core/errors/error_mapper.dart`. Mapping table:
| Cause | Exception |
|---|---|
| `connectionError`, `SocketException` | `NetworkException` |
| connect/send/receive timeout | `TimeoutException` |
| 401 | `UnauthorizedException` |
| 403 | `ForbiddenException` |
| 404 | `NotFoundException` |
| 400/409/422 (field errors when the body has them, otherwise empty) | `ValidationException(fieldErrors: Map<String, List<String>>)` |
| 5xx | `ServerException(statusCode)` |
| cancel | `CancelledException` (not shown to the user) |
| anything else | `UnknownException` |
- The server error body shape is configurable in ONE parser (`ErrorBodyParser`); default understands `{message, errors:{field:[..]}}`.
- User-facing text: `AppException` → localized key via `core/errors/error_messages.dart` (`errors.*`) (`errors.network`, `errors.timeout`, `errors.unauthorized`, …). Server-provided `message` is shown only for `ValidationException`/`ServerException` when the parser marks it as user-safe.

## Repositories
- Signature: `Future<Model> method(...)` throws `AppException`. (No `ApiResult` wrapper.) Repository is a concrete class with a keepAlive provider.
- Models (freezed + json_serializable, `data/models/`) are used directly by providers and pages; JSON never leaves `data/`.
- Pass a `CancelToken` for screens that can be left mid-request; notifiers cancel on dispose.

## Pagination (`core/network/pagination/`)
- `PageRequest` (cursor or offset), `Page<T>(items, nextCursor/nextOffset, hasMore)`.
- `PaginatedController<T>` (a Notifier base) handles first load, `loadMore`, refresh, de-duplication, error-on-next-page without losing items (→ the `partial` state).
- UI: `PaginatedListView` triggers `loadMore` at 80% scroll; footer shows loader / retry / end.

## Upload / download
- `core/network/transfer/`: `uploadFile(path, file, onProgress, cancelToken)` multipart; `downloadFile(url, savePath, onProgress, cancelToken)` to app cache dir with partial-file cleanup on cancel/failure.
- Progress exposed as `Stream<double>`/provider state 0..1; cancellation via `CancelToken`.

## Connectivity
- `connectivityProvider` (stream of online/offline/backOnline) in `core/services/connectivity/`. `OfflineBanner` reads it. On `backOnline` the app invalidates providers marked `refreshOnReconnect`.
- Do not use DNS lookup of a third-party host to decide connectivity; use the connectivity plugin plus request failures as the signal.

## Testing
Fake adapter (`http_mock_adapter` is NOT approved; use a hand-written `HttpClientAdapter` fake in `test/helpers/`). See TESTING.md.

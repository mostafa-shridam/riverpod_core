---
name: new-api-call
description: Add a repository method backed by an API endpoint (DTO, data source, error mapping, tests). Use when a change adds or changes a network call.
---

# new-api-call

Read NETWORKING.md and STATE_AND_DATA.md first. Never create a `Dio` in a feature; use `dioProvider`.

1. Model: `data/models/<thing>.dart` — freezed + json_serializable, `explicitToJson: true`, unknown-enum fallback. Used directly by providers and pages.
2. Data source method in `data/sources/<feature>_remote_source.dart`: path constant, `dio.get/post/...`, parse the model from `response.data`.
   No try/catch for network errors (the interceptor already maps to `AppException`; read `DioException.error`). Writes: do not set your own idempotency key.
3. Repository (`data/<feature>_repository.dart`, concrete class): call the data source, return the model, rethrow `AppException` (unwrap `DioException.error`);
   any other exception -> `UnknownException` with `cause`. No interface, no use case.
4. Paginated endpoint → use `PaginatedController` (do not hand-roll paging). Upload/download → `core/network/transfer`.
5. Cacheable GET → use the SWR helper (`core/storage/cache`) with a key including the user id when user-scoped.
6. Tests (`test/features/<feature>/data/`): `FakeHttpAdapter` responses for success, 401/403/404, 422 with field errors, 500, timeout, no connection;
   assert the repository result or the exact `AppException` subtype; assert JSON-to-model mapping of every field.
7. Run the gate (CLAUDE.md, Definition of done).

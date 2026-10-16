# CONVENTIONS

## Naming
- Files: `snake_case.dart`. One public class per file, file named after it.
- Classes/enums/typedefs: `UpperCamelCase`. Members/variables/functions: `lowerCamelCase`. Constants: `lowerCamelCase` (not SCREAMING).
- Suffixes: `XPage` (route widget, in `presentation/pages/`), `XWidget` only for feature-private widgets, `XRepository` (concrete class, no interface, no `Impl`),
  `XRemoteSource` / `XLocalSource` (in `data/sources/`), models are plain names (`Product`, freezed + json_serializable, no `Dto` suffix), `XState` for freezed state classes, `XException`.
- Generated files: `*.g.dart`, `*.freezed.dart` next to the source file. Never edit, never hand-write.
- Test file: same path under `test/` + `_test.dart`.

## Providers
- Codegen names are derived from the function/class: `userRepository(Ref ref)` → `userRepositoryProvider`;
  `class AuthController` → `authControllerProvider`. Do not set provider prefixes/suffixes in build.yaml beyond the default.
- Repository provider (keepAlive, declared next to the repository): `<feature>RepositoryProvider`. Notifier: `<Thing>Controller` for actions+state, `<thing>(Ref)` functions for pure derived/read-only data.

## Imports
- `dotenv` / `String.fromEnvironment` only inside `core/config`.
- Always package imports (`package:riverpod_core/...`) for anything under `lib/`. No relative imports across folders.
- Order (enforced by `directives_ordering`): dart, package (flutter first), project. One blank line between groups.
- No `import ... show`/`hide` unless resolving a name clash (comment why).

## Formatting & style
- `dart format` default (80 cols). Trailing commas on multi-line argument lists.
- Single quotes. `const` wherever possible. `final` locals. No `dynamic` unless decoding JSON at the DTO boundary.
- Max ~300 lines per file; split when larger. Max one page per file.
- No `print`. Use the logger (`core/logger`).

## Comments
- English only. Explain WHY, not what. No commented-out code, no TODO without a task ID (`// TODO(C-12): ...`).
- Public API of `core/` gets a one-line doc comment (`///`).

## Strings and localization
- No user-visible text in code. Every string comes from `assets/translations/{ar,en}.json` via generated `LocaleKeys`.
- Keys: `feature.screen.element` lowerCamelCase segments, e.g. `auth.login.submit`. Errors under `errors.*`, common under `common.*`.
- Both languages in the same commit; the key-parity test must pass.
- Developer-only strings (logs, assertions) may be English literals.
- Numbers/dates: always via the locale-aware formatters in `core/l10n`, never `toString()` on user-facing values.

## Layout: RTL-safe (logical properties only)
- Use `EdgeInsetsDirectional`, `AlignmentDirectional`, `BorderRadiusDirectional`, `PositionedDirectional`, `TextAlign.start/end`.
- Forbidden for layout: `EdgeInsets.only(left/right)`, `Alignment.centerLeft/Right`, `Positioned(left/right)`, `TextAlign.left/right`.
- Directional icons (back, chevron, send) must mirror: use `matchTextDirection` or icons that flip automatically.
- Never hard-code `TextDirection`.

## UI composition
- One shared primitive per UI element (button, field, card, dialog, sheet, snackbar, avatar, badge, chip, skeleton, image).
  Primitives live only in `lib/core/design_system/widgets/`. Features compose them; never re-implement or restyle locally. Missing variant → ask the Lead for a task to extend the primitive.
- No hard-coded colors, font sizes, spacing, radii, durations in features: use tokens (DESIGN_SYSTEM.md) via `Theme.of(context)` / `context.tokens`. Never use raw `ElevatedButton`/`TextField` etc. in features.
- Never set `textScaler` to a fixed value. Layouts must survive 2.0× text scale.
- Touch targets ≥ 48×48 dp. Add `Semantics` labels to icon-only buttons.

## Async & safety
- Check `context.mounted` after every `await` before using context.
- Dispose controllers, subscriptions, timers.
- Never swallow exceptions silently: handle, map to `AppException`, or rethrow.

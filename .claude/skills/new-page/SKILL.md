---
name: new-page
description: Build a page with all 8 data states, responsive layout, RTL-safe widgets, l10n keys and goldens. Use whenever a task adds or changes a page.
---

# new-page

Read DESIGN_SYSTEM.md and CONVENTIONS.md first.

1. Create `features/<f>/presentation/pages/<name>_page.dart` as a `ConsumerWidget`/`ConsumerStatefulWidget` (one page per file). Add its typed route in `lib/app/router/routes.dart` (go_router_builder) and run codegen.
2. Watch ONE provider (`ref.watch(xControllerProvider)`); side effects via `ref.listen`. No Dio/DB/Navigator calls in logic; navigate with typed routes (`const XRoute().go(context)`).
3. Render data with `AsyncValueView` so all eight states exist: loading (skeleton shaped like the content), empty, error, offline, stale, partial, refreshing (pull-to-refresh), success.
4. Compose only widgets from `lib/core/design_system/widgets/` and tokens from `context.tokens`. Missing primitive -> stop and ask the Lead.
5. Layout: logical properties only; scrollable body so 2.0x text never overflows; adapt by `context.breakpoint` (phone/tablet; max content width 720). Touch targets >= 48 dp; `Semantics` for icon-only controls.
6. Text: every string through `LocaleKeys` (`add-translation-keys` skill). No literals.
7. Tests under `test/features/<f>/presentation/pages/`: a widget test per state (override the provider with a fake), goldens for success and loading (light/dark x ar/en, phone and tablet via `pumpApp`), text scale 2.0 test.
8. Run the gate; report which states/tests exist; set REVIEW.

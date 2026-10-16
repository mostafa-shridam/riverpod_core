# DESIGN SYSTEM (target state)

Material 3, one source of truth in `lib/design_system/` (`tokens/`, `theme/`, `responsive/`, `widgets/`). Generic by default (rule 10):
the template ships a neutral seed palette; each app changes ONE file (`lib/design_system/tokens/brand_config.dart`) to rebrand.

## Tokens
All tokens are `ThemeExtension`s read via `context.tokens` (and `Theme.of(context)` for Material parts).
| Group | Contents |
|---|---|
| Color | Generated from one seed with `ColorScheme.fromSeed` for light and dark + semantic extras: `success`, `warning`, `info` (+ `on*`). No raw hex outside `design_system/tokens/`. |
| Type | Material 3 type scale mapped to `TextTheme`; font family is a config value; sizes are never set in features. |
| Spacing | 4-pt scale: `xxs 2, xs 4, sm 8, md 12, lg 16, xl 24, xxl 32, xxxl 48`. |
| Radius | `sm 8, md 12, lg 16, xl 24, full 999`. |
| Elevation | `none, low, mid, high` mapped to M3 surface tint levels. |
| Motion | `fast 150ms, normal 250ms, slow 400ms` + standard curves. |

## Modes
Light, dark, system. Persisted in prefs, switchable at runtime. Every widget must be checked in both.

## Breakpoints (window width, dp)
`phone < 600`, `tablet 600–1023`, `desktop ≥ 1024`; plus orientation. Exposed via `context.breakpoint` (`design_system/responsive/`).
Use layout builders/adaptive widgets — never fork a whole router per device. Content max width on large screens: 720 dp for forms/lists.

## Shared widgets catalog (`design_system/widgets/`)
| Widget | Use for | Notes |
|---|---|---|
| `AppButton` | every button | variants: primary, secondary, tonal, text, destructive; sizes; `isLoading`; icon slot |
| `AppTextField` | every input | label, hint, helper, error, validator, obscure toggle, prefix/suffix, directional-safe |
| `AppCard` | grouped content | tappable variant |
| `AppDialog` / `showAppDialog` | confirm/alert | title, body, primary/secondary actions |
| `AppBottomSheet` | secondary flows, pickers | drag handle, safe-area aware |
| `AppSnackbar` (`showAppSnackbar`) | transient feedback | types: success/info/warning/error; uses root messenger key |
| `AppSkeleton` | loading placeholders | wraps Skeletonizer config |
| `AppCachedImage` | any network image | placeholder + error widget + fade |
| `AppAvatar`, `AppBadge`, `AppChip` | identity, counts, filters | |
| `AsyncValueView` | every `AsyncValue` in UI | renders the 8 data states (below) |
| `EmptyState`, `ErrorState` | inside the above | icon, title, message, action |
| `OfflineBanner` | connectivity | auto from connectivity provider |
| `PaginatedListView` | infinite scroll | cursor/offset, footer loader/error/end |
Rule: a feature that needs something not in this list asks the Lead for a task; it does not build it locally.

## The 8 data states (every page that loads data)
| State | Meaning | UI |
|---|---|---|
| loading | first load, no data | skeleton matching final layout |
| empty | success with zero items | `EmptyState` with message + optional action |
| error | failed, no data | `ErrorState` with localized message + retry |
| offline | no connectivity, no cached data | `ErrorState` offline variant + retry on reconnect |
| stale | cached data shown while revalidating or offline | data + subtle "last updated" / offline banner |
| partial | some sections/pages failed | data + inline error row with retry for the failed part |
| refreshing | pull-to-refresh / background reload with data | data + refresh indicator, no layout jump |
| success | data present | content |
`AsyncValueView` takes an `AsyncValue<T>` plus flags (`isEmpty`, `isStale`, `hasPartialError`) and implements all eight.
A page is not "done" until each state has a widget test or golden (see TESTING.md).

## Accessibility & localization checks per page
- ar (RTL) and en (LTR) golden; light and dark golden.
- Text scale 1.0 and 2.0 render without overflow.
- Phone and tablet widths.
- Semantics for icon buttons/images; contrast ≥ 4.5:1 for body text.

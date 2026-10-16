# DESIGN SYSTEM (target state)

Material 3, one source of truth in `lib/core/design_system/` (`tokens/`, `theme/`, `responsive/`, `widgets/`). Generic by default (rule 10):
the template ships a neutral seed palette; each app changes ONE file (`lib/core/design_system/tokens/brand_config.dart`) to rebrand.

## Tokens
All tokens are `ThemeExtension`s read via `context.tokens` (and `Theme.of(context)` for Material parts).
| Group | Contents |
|---|---|
| Color | Generated from one seed with `ColorScheme.fromSeed` for light and dark + semantic extras: `success`, `warning`, `info` (+ `on*`). No raw hex outside `core/design_system/tokens/`. |
| Type | Material 3 type scale mapped to `TextTheme`; font family is a config value; sizes are never set in features. |
| Spacing | 4-pt scale: `xxs 2, xs 4, sm 8, md 12, lg 16, xl 24, xxl 32, xxxl 48`. |
| Radius | `sm 8, md 12, lg 16, xl 24, full 999`. |
| Elevation | `none, low, mid, high` mapped to M3 surface tint levels. |
| Motion | `fast 150ms, normal 250ms, slow 400ms` + standard curves. |
| Sizes | Component sizes: button height `sm 40, md 48, lg 56`; icons `18/20/24`; `minTouchTarget 48`; OTP box `48×56`; outline `1`, focused outline `2`, spinner stroke `2`. Search debounce `300ms` (in Motion). |

The resolved light/dark color role table (seed `#4A6FA5`, success/warning/info accents) is in `ai-docs/reports/C-05.md`. Dark mode uses the dark tonal palette (surfaces `#111318` → `#32353A`), not an inverted light scheme.

## Modes
Light, dark, system. Persisted in prefs, switchable at runtime. Every widget must be checked in both.

## Breakpoints (window width, dp)
`phone < 600`, `tablet 600–1023`, `desktop ≥ 1024`; plus orientation. Exposed via `context.breakpoint` (`core/design_system/responsive/`).
Use layout builders/adaptive widgets — never fork a whole router per device. Content max width on large screens: 720 dp for forms/lists.

## Shared widgets catalog (`core/design_system/widgets/`)
Folder rule: one folder per widget family, one file per widget (`app_button.dart`, not a mega-file), so anyone can find a widget by browsing. Each primitive has ONE implementation here. A feature that needs something missing asks the Lead for a task.
| Folder | Widgets | Task |
|---|---|---|
| `buttons/` | `AppButton` (primary, secondary, tonal, outlined, text, destructive; sizes; loading; icons; full width), `AppIconButton`, `AppFab` | C-09 |
| `inputs/` | `AppTextField`, `AppPasswordField`, `AppSearchField`, `AppOtpField`, `AppPhoneField` | C-09 |
| `selection/` | `AppCheckbox`, `AppRadioGroup`, `AppSwitch`, `AppDropdown`, `AppSegmentedControl`, `AppSlider`, `AppDateField`, `AppTimeField`, `AppRating`, `AppChipGroup`, `AppFormField` | C-32 |
| `bottom_sheets/` | `showAppBottomSheet` (+ `AppActionSheet`, `AppSelectionSheet`, `AppFormSheet`) | C-33 |
| `dialogs/` | `showAppDialog` (+ `AppAlertDialog`, `AppConfirmDialog`, `AppInputDialog`, `AppLoadingDialog`/`AppLoadingOverlay`) | C-33 |
| `feedback/snackbar/`, `feedback/progress/`, `feedback/banner/`, `feedback/tooltip/` | `showAppSnackbar`/`showAppToast`, `AppMessenger`; `AppProgressBar`, `AppProgressIndicator`; `AppBanner`; `AppTooltip` | C-33 |
| `display/` | `AppCard`, `AppListTile`, `AppSectionHeader`, `AppDivider`, `AppAvatar`, `AppBadge`, `AppChip`, `AppImage`, `AppAccordion` | C-34 |
| `layout/` | `AppScaffold`, `AppAppBar`, `AppTabBar`, `AppBottomNavBar`, `AppStepper` | C-34 |
| `async/` | `AsyncValueView`, `EmptyState`, `ErrorState`, `Skeleton`, `OfflineBanner`, `PaginatedListView` | C-10, C-14 |
The gallery page (`/showcase`, dev/staging only, C-35) shows every widget live in light/dark, ar/en and any text scale.

### Look and feel (why it looks like this)
- Material 3 base, softened: radius `md 12` for controls, `lg 16` for cards, `xl 24` for sheets and dialogs; low elevation, surface-tint instead of heavy shadows.
- Modal bottom sheet: drag handle, rounded top, scrim at 40% of `scrim`, content respects safe area and keyboard, max width 560 on tablets.
- Dialogs: icon on top for status variants, title + body centered-start aligned (directional), buttons stacked on narrow widths.
- Toast/snackbar: floating, rounded, colored by type with icon, one visible at a time.
- Motion: `normal 250 ms` ease-out for enter, `fast 150 ms` for exit; no motion when the system disables animations.

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

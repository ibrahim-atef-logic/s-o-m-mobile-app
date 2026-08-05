# Design System — Sales Orders Management

Light-theme token system used across all Flutter screens.

## Principles

- Comfortable warehouse UX: 56dp primary buttons, 48dp minimum touch targets
- Arabic-first (RTL default) with Latin digits for quantities, prices, barcodes
- Content-shaped shimmer skeletons for list loading; in-button spinner only for submits
- All user-facing copy via `AppLocalizations` (en / ar)

## Tokens

| File | Contents |
|------|----------|
| `lib/core/theme/app_colors.dart` | Brand, semantic, neutrals, text, shimmer |
| `lib/core/theme/app_text_styles.dart` | Cairo type scale + tabular `numeric` |
| `lib/core/theme/app_dimensions.dart` | Spacing, radius, icons, motion |
| `lib/core/theme/app_shadows.dart` | Soft card / raised / sticky shadows |
| `lib/core/theme/app_theme.dart` | Assembles `ThemeData` |
| `lib/core/theme/component_themes/` | Buttons, inputs, surfaces |

## Shared components (`lib/core/widgets/`)

- `PrimaryButton` / `SecondaryButton` — loading-aware
- `AppCard` — tappable surface card
- `StatusChip` — success / warning / danger / info / neutral
- `KeyValueRow`, `SectionLabel`, `QuantityStepper`
- `StickyActionBar`, `showAppSnackBar`, `LanguageSwitcher`
- `BarcodeScannerPanel` — reticle, torch, last-scanned strip
- Skeletons under `skeletons/` — `ShimmerBox`, list/card/line/company/failed/lookup
- States under `states/` — `AppEmptyView`, `AppErrorView` (retry + details)

## Localization

- Default locale: Arabic (`LocaleCubit` + `StorageKeys.localeCode`)
- Switcher: Hello screen (segmented) + orders app bar (menu)
- Failures: `Failure.localizedTitle(l10n)` — never show raw English defaults as titles
- Numbers: `AppFormat.quantity/price/date` always Latin digits

## Loading rules

1. List/fetch screens → content-shaped shimmer
2. Submit / confirm → `PrimaryButton(isLoading: true)`
3. Errors → `AppErrorView` with retry; technical text in expandable details
4. Empty → `AppEmptyView` with optional CTA

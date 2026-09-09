# Design System — Sales Orders Management

Light-theme token system used across all Flutter screens. **This file is the
source of truth** for UI. Code in `lib/core/theme/` and `lib/core/widgets/`
must match this document.

## Principles

- Comfortable warehouse UX: 56dp primary buttons, 48dp minimum touch targets
- Arabic-first (RTL default) with Latin digits for quantities, prices, barcodes
- Content-shaped shimmer skeletons for list loading; in-button spinner only for submits
- All user-facing copy via `AppLocalizations` (en / ar)
- Prefer `context.textTheme` / `context.numericStyle` (`lib/core/extensions/theme_context.dart`); `AppTextStyles` is the token source consumed only by `buildAppTheme()` and theme component files
- Evolve the Teal + Cairo identity — no rebrand, no bottom navigation in v1

## Do / Don't

| Do | Don't |
|----|--------|
| Use `AppColors` / `AppDimensions` / `context.textTheme` | Inline `Color(0x…)`, magic spacing, raw `TextStyle` |
| Use `AppFormat` (incl. `dash` / `pending`) | Format with locale-dependent Arabic digits |
| Use `DirectionalChevron` / `AppSelectableTile` | Hardcode `Icons.arrow_forward_ios` / `chevron_right` |
| Use `AppEmptyView` / `AppErrorView` | Ad-hoc empty/error columns |
| Use `AppValidationText` for form errors | Raw `TextStyle(color: danger)` |
| Show friendly l10n snackbars | Dump raw D365 exception text |
| Give tappable surfaces `Semantics` + ≥48dp | Icon-only controls without labels |

## Tokens

| File | Contents |
|------|----------|
| `lib/core/theme/app_colors.dart` | Brand, semantic, neutrals, text, on-container, shimmer |
| `lib/core/theme/app_text_styles.dart` | Cairo type scale + tabular `numeric` |
| `lib/core/theme/app_dimensions.dart` | Spacing, radius, icons, stroke, scanner, shimmer, motion |
| `lib/core/theme/app_gradients.dart` | `brand`, `brandVivid`, `brandTint`, `pageWash`, `tonal(color)` |
| `lib/core/theme/app_shadows.dart` | Soft card / raised / sticky / modal / `brand` CTA lift |
| `lib/core/theme/app_theme.dart` | Assembles `ThemeData` (+ tooltip / icon themes) |
| `lib/core/theme/component_themes/` | Buttons, inputs, surfaces |

### Icon sizes

`iconSm` 16 · `iconMd` 24 · `iconLg` 32 · `iconXl` 40 · `iconHero` 56 · `iconDisplay` 64

### Stroke

`strokeHairline` 0.5 · `strokeThin` 1 · `strokeFocus` 2 · `spinnerStroke` 2.5

### Radius

`radiusSm` … `radiusXl` 20 · `radius2Xl` 24 (headers, sticky bars) · `radius3Xl` 28 (hero panels) · `radiusPill`

### Badges

`badgeSm` 32 · `badgeMd` 44 · `badgeLg` 56 · `heroAvatar` 72 · `heroHeaderMinHeight` 132

## Visual layer

The brand gradient is the app's structural signal. Apply it in exactly three places:

1. **Chrome** — `AppGradientAppBar` on every screen with an app bar.
2. **Hero / header panels** — `AppHeroHeader` (with `AppHeroStat` children) or a
   gradient search header at the top of a list; rounded bottom via `radius2Xl`.
3. **Primary CTA** — `PrimaryButton` (`brandVivid` vertical gradient + tight
   `AppShadows.brand` lift). Both gradient stops stay dark enough for white
   labels to pass AA; keep the shadow tight so edges read crisp, not blurred.

Everything below the header sits on `AppGradients.pageWash` with white
`AppCard` surfaces. Never paint a gradient on a content card; use
`AppCardVariant.tonal` or `AppGradients.tonal(color)` instead.

## Shared components (`lib/core/widgets/`)

- `PrimaryButton` / `SecondaryButton` — loading-aware (primary = brand gradient)
- `AppGradientAppBar` — brand-gradient app bar
- `AppHeroHeader` + `AppHeroStat` + `AppStatCard` — screen-opening panels and metrics
- `AppCard` — surface card; `variant` (`surface` / `tonal` / `outlined`) + `accentColor` rail
- `AppIconBadge` — tonal rounded icon container (`sm` / `md` / `lg`, `filled`)
- `AppSectionHeader` — section title with accent rule and optional trailing action
- `AppActionTile` — card-shaped navigation row (badge + title + chevron)
- `ContextRow` — badge + label + value row for session/order metadata
- `AppListTile` / `AppSelectableTile` — list + picker rows
- `AppTextField` / `AppPasswordField` / `AppSearchField` — themed inputs
- `AppValidationText` — danger caption for form errors
- `AppPageScaffold` — standard padding list body
- `DirectionalChevron` — mirrored navigation affordance
- `AddFlowStepHeader` — Full-add / Quick-add step chrome
- `StatusChip` — success / warning / danger / info / neutral
- `KeyValueRow`, `SectionLabel`, `QuantityStepper`
- `StickyActionBar` (+ `.summary` for footer-only bars)
- `showAppSnackBar`, `LanguageSwitcher`
- `BarcodeScannerPanel` — reticle, torch, last-scanned strip
- Skeletons under `skeletons/` — `ShimmerBox`, list/card/line/company/failed/lookup
- States under `states/` — `AppEmptyView`, `AppErrorView` (retry + details), `AppStateGlyph`

## Accessibility & overflow

- Interactive elements: `Semantics(button: true, label: …)` and `tooltip` where applicable
- Minimum touch target: `AppDimensions.minTouchTarget` (48)
- Titles/subtitles in tiles: `maxLines` + `TextOverflow.ellipsis`
- Quantity stepper semantics localized (`decreaseQuantity` / `increaseQuantity`)

## Localization

- Default locale: Arabic (`LocaleCubit` + `StorageKeys.localeCode`)
- Switcher: Hello screen (segmented) + orders app bar (menu)
- Failures: `Failure.localizedTitle(l10n)` — never show raw English defaults as titles
- Numbers: `AppFormat.quantity/price/date` always Latin digits
- Password change: always `l10n.passwordChanged` / `l10n.errorPasswordChangeFailed` (never D365 raw text)

## Loading rules

1. List/fetch screens → content-shaped shimmer
2. Submit / confirm → `PrimaryButton(isLoading: true)`
3. Errors → `AppErrorView` with retry; technical text in expandable details
4. Empty → `AppEmptyView` with optional CTA
5. Inline lookups (price/stock) → small spinner in place, not full-page skeleton

## RTL rules

- Use `EdgeInsetsDirectional`, `AlignmentDirectional`, `TextAlign.start`
- Navigation trailing icons via `DirectionalChevron`
- Shimmer and lists must respect `Directionality`

## Golden tests

- Package: `golden_toolkit`
- Helpers: `test/golden/golden_helpers.dart`
- Update: `flutter test --update-goldens test/golden`
- Coverage: `core_and_auth_goldens_test.dart` (empty/error/order chrome) and
  `visual_kit_goldens_test.dart` (hero header + gradient app bar EN 360, list chrome AR 412)

## Per-screen acceptance

See [SCREEN_INVENTORY.md](SCREEN_INVENTORY.md). Each screen must satisfy:

1. No raw colors/spacing/font sizes outside tokens
2. States: loading / empty / error / success as applicable
3. Touch targets ≥ 48dp; primary CTA height 56dp
4. RTL-safe chrome
5. Numbers via `AppFormat`

## Dark theme

**Explicitly deferred** until light system is stable across all journeys. When added:
`AppColorsDark` + `buildAppTheme(Brightness)` — not part of the current hardening wave.

## Related

- Screen inventory: [SCREEN_INVENTORY.md](SCREEN_INVENTORY.md)
- Architecture (API/data): repo root `ARCHITECTURE.md`

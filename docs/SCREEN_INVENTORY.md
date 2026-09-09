# Screen inventory

Status legend: **Refreshed** · **Tokens OK** · **Needs pass** · **Broken link** · **Orphan** · **Removed**

"Refreshed" = token-clean *and* on the visual layer (gradient chrome, hero or
gradient search header, card surfaces on `pageWash`).

| Route | Page | Status | Notes |
|-------|------|--------|-------|
| `/hello` | HelloPage | Refreshed | Full gradient canvas + white action sheet |
| `/login` | LoginPage | Refreshed | Gradient app bar, brand mark, form in card |
| `/warehouse` | WarehousePickerPage | Refreshed | Gradient search header + selectable tiles |
| `/profile` | ProfilePage | Refreshed | Identity hero + stats, `AppActionTile` security row |
| `/profile/change-password` | ChangePasswordPage | Refreshed | Hero + card form; friendly l10n snackbars only |
| `/orders` | MySalesOrdersPage | Refreshed | Gradient search header, badge order tiles, extended FAB |
| `/orders/new` | CreateOrderPage | Refreshed | `ContextRow` session card + sticky gradient CTA |
| `/orders/new/customer` | CustomerPickerPage | Refreshed | Gradient search header + selectable tiles |
| `/orders/:salesId` | SalesOrderDetailsPage | Refreshed | Hero + live total stat + accented action grid |
| `/orders/:salesId/lines` | SoLinesPage | Refreshed | Badge line tiles with money strip + summary footer |
| `/orders/:salesId/full-add` | FullAddCartPage | Refreshed | Accent cart tiles + summary footer |
| `/orders/:salesId/full-add/scan` | FullAddScanPage | Refreshed | Scan / quantity cards, framed scanner |
| `/orders/:salesId/quick-add` | QuickAddCartPage | Refreshed | Swipe-to-remove accent tiles + sticky submit |
| `/orders/:salesId/quick-add/scan` | QuickAddScanPage | Refreshed | Step header + scan / quantity cards |
| `/orders/:salesId/failed-lines` | FailedLinesPage | Refreshed | Danger accent tiles + tonal reason block |
| — | CompanySelectPage | Removed | Dead UI deleted (login supplies company) |

## Acceptance checklist (copy per PR)

- [ ] No `Color(0x…)` / magic padding in changed presentation files
- [ ] Gradient used only for chrome, hero panels, and primary CTA
- [ ] Loading / empty / error covered
- [ ] Primary button 56dp; icons from `AppDimensions`
- [ ] AR + EN smoke on changed screens
- [ ] Existing bloc/widget tests still pass
- [ ] Goldens updated when chrome changes (`flutter test --update-goldens test/golden`)

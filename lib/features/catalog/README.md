# Catalog

Remote lookups: barcode, warehouse on-hand (`availableSalesQuantity` +
`unit` / ConvertedUnitSymbol), channel item-price (`POST /api/v1/item-price`),
submit full/quick lines, failed lines.

Full-add prices with `salesUnitId` = inventory `unit` when present; otherwise
barcode `unitId`. Display price is always `finalPrice` (+ `currency`) — never
recomputed from list price / markup / lineDisc. UI never shows
`availableOnHandQuantity` on product details.

Older `GET /pricing` is not used by full-add.

`itemId` is the barcode `itemNumber` after `trim()` only — never padded.
Example: barcode `6287007961754` → `itemId` is exactly `BG410.003` (9 chars).
`salesUnitId` is barcode `unitId` as-is after trim (e.g. `حبة`).

`ITEM_NOT_FOUND` / `NO_PRICE` are shown as `errorNoPrice`. D365
`GetItemPrice` can miss an item that still has a trade-agreement row on
`GET /api/v1/pricing` (different lookup). The app must not fall back to
that older price.

Full-line POST sends `"ifExists": "add"` so a second scan of the same item
increases quantity instead of 409 `LINE_ALREADY_EXISTS`. Quick-add has no
`ifExists`; an all-duplicate batch is still 409 and is shown as
`errorLineAlreadyExists`.

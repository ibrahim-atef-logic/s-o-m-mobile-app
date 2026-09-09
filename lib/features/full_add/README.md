# Full add

Scan/enter barcode → inventory (`availableSalesQuantity` + `unit` /
ConvertedUnitSymbol) → `POST /item-price` with `salesUnitId` = inventory unit
(fallback: barcode `unitId`) → show `finalPrice` + currency → quantity
validation → POST full line with `ifExists: add`.

UI never shows `availableOnHandQuantity`. A second scan of the same item
increases D365 quantity and merges the session cart row.

# SO lines

List of Dynamics sales order lines (`GET .../sales-orders/{id}/lines`).

The header scan bar is hardware-first: the TextField stays focused so an
EDA51 trigger (or keyboard wedge) writes the barcode. Mode **Barcode** opens
the add-item sheet; mode **Item** filters the loaded lines by item id / name.

Display amounts come from D365 `netAmount` (and `unitPrice` for reference).
Footer total is `sum(netAmount)`. Line delete waits on
`DELETE /api/v1/sales-orders/{salesId}/lines/{recordId}`.

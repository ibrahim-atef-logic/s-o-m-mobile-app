# Sales orders

Lists open Dynamics sales orders for the selected company and shows header details.

## Create order (FAB on the list)

1. DataArea = `user.inventLocationDataAreaId ?? activeCompany ?? company`.
2. Warehouse = `user.activeWarehouse`. If it is missing, the picker opens on
   the create-order screen only — never after login.
3. Customer comes from the customers picker, preselected with
   `user.defaultCustAccount` when set.
4. `POST /api/v1/sales-orders` with `company`, `custAccount`,
   `inventLocationId`. Currency is omitted so the backend resolves it from the
   session/customer. The sales taker is resolved from the JWT and is never sent.

The list is sorted by `createdDateTime` (newest first) when the API sent dates,
otherwise by sales order number.

On success the header is re-read with `GET /api/v1/sales-orders/{id}` so price
group and status are real, the list refreshes, and the order detail opens.

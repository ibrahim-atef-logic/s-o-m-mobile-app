# Customers

Server-side customer search for the create-sales-order flow, via the .NET API
only (`GET /api/v1/customers?company={dataAreaId}&search={term}&top=50`).

- `company` is the D365 DataArea (e.g. `mm`), never the login registry key.
- Search runs on the backend; typing is debounced ~400ms and `top` is capped at
  200.
- Today `search` only matches a **complete** account number: D365 F&O OData
  rejects `contains`/`startswith` in `$filter` ("The type 'System.String' for the
  query operator is not Queryable!"), so the backend can only use `eq`, and the
  41k customers of `mm` are too many to filter in process. Partial terms and
  names return an empty list, which is why the field says "full account number".
  A D365 X++ search action is being added; once the backend swaps its filter for
  it the API contract stays identical, so only these two strings
  (`searchCustomers`, `noCustomers`) need to go back to account-or-name wording.
- The picker pops the chosen `CustomerEntity`; Arabic names render with the
  ambient text direction.

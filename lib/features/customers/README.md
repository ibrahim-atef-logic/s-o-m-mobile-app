# Customers

Server-side customer search for the create-sales-order flow, via the .NET API
only (`GET /api/v1/customers?company={dataAreaId}&search={term}&top=50`).

- `company` is the D365 DataArea (e.g. `mm`), never the login registry key.
- Search runs on the backend over account number and name; typing is debounced
  ~400ms and `top` is capped at 200.
- The picker pops the chosen `CustomerEntity`; Arabic names render with the
  ambient text direction.

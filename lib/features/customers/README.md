# Customers

Server-side customer search for the create-sales-order flow, via the .NET API
only (`GET /api/v1/customers?company={dataAreaId}&search={term}&top=30&skip=0`).

- `company` is the D365 DataArea (`activeCompany`, e.g. `mm`), never the login
  registry key (`logic-trial`).
- Typing is debounced 300ms; `top` is capped at 100 per request.
- **Browse** (empty `search`): OData paginated list with `hasMore` + load-more.
- **Search** (non-empty `search`): backend cached index — exact account, account
  prefix, name contains (Arabic-safe), phone/city. Response includes
  `totalCount` (total matches before skip/top).
- Mobile merges local browse-cache hits when the server returns empty (cold
  index warm-up fallback).
- The picker pops the chosen `CustomerEntity`; Arabic names render with the
  ambient text direction.

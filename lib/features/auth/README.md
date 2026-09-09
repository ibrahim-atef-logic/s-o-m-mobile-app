# Auth

Login with environment/tenant code + personnelNumber + password against the
**.NET API only** (`POST /api/v1/auth/login`). The device never calls D365 OData.

- Form `company` is the registry key (e.g. `logic-trial`), not the legal entity.
- Operating DataArea for catalog/SO APIs is `user.activeCompany` (fallback `user.company`).
- Branch UI prefers `user.retailChannelName` (live on login/me/refresh), then
  `retailChannelId`, then warehouse. Debug builds log user keys only when the
  name is missing.
- Full login `data` (tokens + user, including display/name fields) is held in
  memory only (`AuthSessionStore`); nothing is written to secure storage or
  preferences. Cold start is always signed out — re-login (or Profile refresh
  via `GET /auth/me`) loads display names again.
- Profile UI uses `displayCompanyName` / `displayWarehouseName` (never raw
  `activeCompany` / `activeWarehouse` when a display label exists). Warehouse
  row shows `profileSelectWarehouse` when `needsWarehouseSelection === true`.
- `wipeStoredSession` deletes session keys left by older builds.
- `POST /api/v1/auth/refresh` only renews an expired access token inside a live
  session; it can never revive a dead one.
- `GET /api/v1/auth/me` reconciles the profile cache.
- `POST /api/v1/auth/change-password` uses the JWT subject (no personnel number).

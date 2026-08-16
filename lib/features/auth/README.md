# Auth

Login with environment/tenant code + personnelNumber + password against the
**.NET API only** (`POST /api/v1/auth/login`). The device never calls D365 OData.

- Form `company` is the registry key (e.g. `logic-trial`), not the legal entity.
- Operating DataArea for catalog/SO APIs is `user.activeCompany` (fallback `user.company`).
- Full login `data` (tokens + user) is held in memory only (`AuthSessionStore`);
  nothing is written to secure storage or preferences.
- Cold start is always signed out. `wipeStoredSession` deletes session keys left
  by older builds, and killing the app means a full re-login.
- `POST /api/v1/auth/refresh` only renews an expired access token inside a live
  session; it can never revive a dead one.
- `GET /api/v1/auth/me` reconciles the profile cache.
- `POST /api/v1/auth/change-password` uses the JWT subject (no personnel number).

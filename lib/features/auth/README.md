# Auth

Login with environment/tenant code + personnelNumber + password against the
**.NET API only** (`POST /api/v1/auth/login`). The device never calls D365 OData.

- Form `company` is the registry key (e.g. `logic-trial`), not the legal entity.
- Operating DataArea for catalog/SO APIs is `user.activeCompany` (fallback `user.company`).
- Full login `data` (tokens + user) is cached in secure storage.
- Cold start restores the session, then `POST /api/v1/auth/refresh` replaces the cached user.
- `GET /api/v1/auth/me` reconciles the profile cache.
- `POST /api/v1/auth/change-password` uses the JWT subject (no personnel number).

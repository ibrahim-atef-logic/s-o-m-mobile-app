# Logic Retail Mobile

Flutter Android/iOS — Clean Architecture (`.cursorrules`).

## Features (complete)

- Auth + multi-company
- Sales orders + existing lines
- Full add (barcode / scanner / price / stock)
- Quick add (max 10 batch)
- Failed lines (AR/EN)

## Backend

Default API: **https://salesorderapp.logictec.online**  
(config: `lib/core/constants/app_constants.dart`)

Do **not** use `hr-admin.logictec.online` / `hrapp.logictec.online` (ERM HR).

## Run

```bash
cd mobile

# Live salesorderapp (default)
flutter run

# Local API on emulator (optional)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

Trial login: company `logic-trial` / personnel `1006` / password `123`

## Tests

```bash
flutter test
```

## Environments

See [`ENVIRONMENTS.md`](ENVIRONMENTS.md).

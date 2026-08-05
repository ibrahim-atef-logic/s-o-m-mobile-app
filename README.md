# Logic Retail Mobile

Flutter Android/iOS — Clean Architecture (`.cursorrules`).

## Features (complete)

- Auth + multi-company
- Sales orders + existing lines
- Full add (barcode / scanner / price / stock)
- Quick add (max 10 batch)
- Failed lines (AR/EN)

## Run

```bash
# Backend
cd backend && npm run dev

# Android emulator
cd mobile
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000

# iOS simulator / desktop
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

Login: `EMP001` / `1234`

## Tests

```bash
flutter test
```

## Environments

See [`ENVIRONMENTS.md`](ENVIRONMENTS.md).

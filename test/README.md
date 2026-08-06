# Tests

## Unit / widget (no network)

```bash
flutter test --exclude-tags e2e
```

## All tests including live e2e

```bash
flutter test
```

## Live e2e only

```bash
flutter test --tags e2e --dart-define=API_BASE_URL=https://salesorderapp.logictec.online
```

Optional defines (defaults match trial staging fixtures):

- `E2E_COMPANY` (default `logic-trial`)
- `E2E_PERSONNEL` (default `1006`)
- `E2E_PASSWORD` (default `123`)
- `E2E_LEGAL_ENTITY` (default `mm`)
- `ENABLE_WRITE_E2E=true` to run the quick-add write scenario (E2E-11)

E2e tests hit the live backend and are tagged `e2e` in `dart_test.yaml`.

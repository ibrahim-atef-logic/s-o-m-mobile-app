# Environments

Single switch via `--dart-define`. Default (no define) is the live Sales Order API.

| ENV | API_BASE_URL | Notes |
|-----|--------------|-------|
| *(default)* | `https://salesorderapp.logictec.online` | Production live backend |
| dev (local API) | `http://10.0.2.2:3000` (emulator) / `http://localhost:3000` | Local .NET API only |
| staging | staging HTTPS URL when available | Full auth |
| prod | `https://salesorderapp.logictec.online` | Obfuscate release builds |

**Do not** point this app at `hr-admin.logictec.online` or `hrapp.logictec.online` (ERM HR).

## Run

```bash
# Live (default — salesorderapp)
flutter run

# Explicit live URL
flutter run --dart-define=ENV=prod --dart-define=API_BASE_URL=https://salesorderapp.logictec.online

# Local Mock/Live API on machine (emulator)
flutter run --dart-define=ENV=dev --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

## Release

```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info \
  --dart-define=ENV=prod --dart-define=API_BASE_URL=https://salesorderapp.logictec.online

flutter build ipa --release --obfuscate --split-debug-info=build/debug-info \
  --dart-define=ENV=prod --dart-define=API_BASE_URL=https://salesorderapp.logictec.online
```

## Config location

`lib/core/constants/app_constants.dart` → `AppConstants.apiBaseUrl` / `apiBaseUrlNormalized`

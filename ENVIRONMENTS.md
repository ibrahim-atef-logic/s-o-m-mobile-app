# Environments

Build with:

```bash
flutter run --dart-define=ENV=dev --dart-define=API_BASE_URL=http://10.0.2.2:3000
flutter run --dart-define=ENV=staging --dart-define=API_BASE_URL=https://api-staging.example.com
flutter run --dart-define=ENV=prod --dart-define=API_BASE_URL=https://api.example.com
```

| ENV | API | Logging | Notes |
|-----|-----|---------|-------|
| dev | localhost / emulator | verbose Dio | HTTP allowed only here |
| staging | staging HTTPS | limited | Full auth |
| prod | prod HTTPS | crash only | Obfuscate release builds |

Release:

```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info \
  --dart-define=ENV=prod --dart-define=API_BASE_URL=https://api.example.com

flutter build ipa --release --obfuscate --split-debug-info=build/debug-info \
  --dart-define=ENV=prod --dart-define=API_BASE_URL=https://api.example.com
```

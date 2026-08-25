# Integration test (E2E smoke)

`app_smoke_test.dart` boots the **real app shell** in mock-auth mode (zero
network) and taps through the five navigation tabs, asserting one key element
per tab:

splash → login (`demo@gewerber.de`) → onboarding ("Demo GmbH") →
Dashboard → Invoicing → Time → Accounting → Settings

## Run

```bash
# Linux desktop (verified in CI-like environments):
flutter test integration_test -d linux

# Web (Chrome / Chromium):
flutter test integration_test -d chrome

# Android device or emulator:
flutter test integration_test -d <device-id>   # see: flutter devices
```

Notes:

- The window size determines which navigation surface the flow uses
  (bottom `NavigationBar` below 900 px width, `NavigationRail` at 900+);
  both are exercised through the same label-based taps.
- The composition mirrors `lib/main_dev.dart`: `FlavorConfig` is initialized
  with `authMode: mock` before the DI container is configured
  (`configureDependencies(environment: AppEnvironment.authMock)`), so no
  Serverpod connection is attempted.
- This directory is not picked up by plain `flutter test`; compilation is
  still covered by `dart analyze`.

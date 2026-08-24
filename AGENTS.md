# AGENTS.md — gewerber-app

Flutter client application for Gewerber (web, mobile, desktop). The app UI is served at `app.gewerber.de`.

## Stack

- Flutter (single codebase for web/mobile/desktop)
- Consumes the generated Serverpod client SDK from `gewerber-backend`

## Commands

```bash
flutter run -d chrome   # run web app
flutter test            # UI/logic tests
dart analyze            # required before PR
dart format .           # required before PR
```

## Conventions

- Keep widgets small and composable; follow the org [BRAND_BOOK.md](https://github.com/Gewerber/.github/blob/main/BRAND_BOOK.md).
- Shared UI Kit components live in this repo — reuse before adding new ones.
- Do not put backend/business logic in the client; it belongs in `gewerber-backend`.

## Open-Core Boundary

This is a public OSS repository covering the open-source core UI only. Do not add closed-module (banking, tax/ELSTER, employees, subscriptions, AI assistant) logic here.

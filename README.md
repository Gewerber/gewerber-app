# 📱 Gewerber App

![Flutter](https://img.shields.io/badge/Flutter-blue?logo=flutter&logoColor=white&style=flat-square)
![Dart](https://img.shields.io/badge/Dart-%230175C2?logo=dart&logoColor=white&style=flat-square)
![Platforms](https://img.shields.io/badge/platform-web%20%7C%20mobile%20%7C%20desktop-blue?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat-square)

The **Gewerber** client application — mobile, web, and desktop in a single Flutter codebase. Hosts the application UI at [https://app.gewerber.de](https://app.gewerber.de) and includes the shared UI Kit.

Part of the [Gewerber GitHub organization](https://github.com/Gewerber).

---

## 🧱 Stack

- **Flutter** — web, mobile, desktop
- **Serverpod client SDK** — generated from `gewerber-backend`

---

## 🚀 Getting Started

### Requirements

- Flutter SDK
- Dart SDK

### Run the web app

```bash
flutter run -d chrome                       # production entry (lib/main.dart)
flutter run -t lib/main_dev.dart -d chrome      # dev flavor (mock auth, red banner)
flutter run -t lib/main_staging.dart -d chrome  # staging flavor (test backend, orange banner)
```

Flavors are configured with [`flutter_flavor`](https://pub.dev/packages/flutter_flavor).
Each entry point (`lib/main.dart`, `lib/main_dev.dart`, `lib/main_staging.dart`)
initializes a `FlavorConfig` with its backend URL, auth mode and banner; the
banner is hidden in production. `--dart-define=SERVER_HOST=...` and
`--dart-define=AUTH_MODE=live|mock` still override the flavor defaults.

### Run on a device

```bash
flutter devices
flutter run
```

### Tests

```bash
flutter test
```

---

## 🚢 Deployment

Deployment is automated with GitHub Actions (`.github/workflows/deploy.yml`):

- push to **`main`** → builds the image, pushes to GHCR and deploys to
  **https://app.gewerber.de** (GitHub environment `production`)
- push to **`develop`** → same, to **https://test.app.gewerber.de** (environment
  `staging`)

The workflow builds the Flutter Web output (`flutter build web`), sets it into
an nginx image, pushes it to GHCR, then copies `docker-compose.yml` +
`deploy/deploy.sh` to the VPS over SSH and runs the deploy. The VPS already runs
Docker and [Traefik](https://traefik.io/); the compose file attaches the
container to Traefik's network via labels (router names are prefixed per
environment so both instances can run side by side). nginx serves the static
build with SPA fallback (Flutter client-side routing) so deep links resolve.

Required repository/environment **secrets**:

| Secret | Purpose |
|---|---|
| `VPS_HOST` | VPS address |
| `VPS_USER` | SSH user |
| `VPS_SSH_KEY` | SSH private key (deploy key) |
| `GHCR_TOKEN` | PAT (`read:packages`) for the VPS to pull the image |

To deploy manually on the VPS:

```bash
bash deploy/deploy.sh prod ghcr.io/gewerber/gewerber-app:prod-latest
bash deploy/deploy.sh test ghcr.io/gewerber/gewerber-app:test-latest
```

### Local build & preview

```bash
docker compose build && docker compose up -d   # serves the app via nginx
```

The image build is multi-stage: `flutter build web` runs inside the
container and nginx serves the resulting static build with SPA fallback,
so no host-side build is required.

---

## 🧭 Related

- [Backend](https://github.com/Gewerber/gewerber-backend)
- [Contributing Guide](https://github.com/Gewerber/.github/blob/main/CONTRIBUTING.md)
- [Organization Structure](https://github.com/Gewerber/.github/blob/main/ORGANIZATION.md)
- [Brand Book](https://github.com/Gewerber/.github/blob/main/BRAND_BOOK.md)

---

## 📄 License

Licensed under the [MIT License](LICENSE).

# syntax=docker/dockerfile:1

# ---- Build stage ---------------------------------------------------------
# All dependencies are public (backend client and the commercial client stubs
# resolve from GitHub without authentication) — no build secrets required.
#
# Base image: openruntimes/flutter with an explicit Flutter minor pin
# (`v5-3.47` = Flutter 3.47.x / Dart 3.13.x, matching the workspace SDK
# ^3.13.3 and CI's flutter-version). The former ghcr.io/cirruslabs/flutter
# `stable`/`latest` tags lagged the release channel (bundled a Dart below the
# workspace SDK floor, breaking `pub get`) and have no 3.47.x version tags.

FROM openruntimes/flutter:v5-3.47 AS build

WORKDIR /app

# Resolve dependencies first for better layer caching. `pubspec.lock` is
# gitignored (*.lock), so only the manifest is copied; `flutter pub get`
# generates the lock (and will honor one if it happens to be present).
COPY pubspec.yaml ./
RUN flutter pub get

# Copy the source and build the web app (releases into build/web/).
# SERVER_HOST is baked in at build time (the app resolves the API endpoint
# from `--dart-define=SERVER_HOST`, see lib/core/config/app_config.dart).
# CI passes the environment-specific backend URL; the default targets
# production (https://api.gewerber.de).
#
# GEWERBER_DEP_REF: branch deploys pass the branch they build (develop →
# staging). For any non-main value a pubspec_overrides.yaml is generated that
# pins the whole inter-repo chain (gewerber_backend_client + the commercial
# stub) to that ref via dependency_overrides — which pub applies across the
# entire resolution graph, including the git-fetched backend client pubspec
# that still commits `ref: main` for the stubs. (Rewriting only the local
# pubspec leaves that transitive requirement and pub fails on the main-vs-
# develop source conflict.) Default main keeps the committed refs —
# production and plain builds are unchanged. `.dockerignore` drops any
# developer pubspec_overrides.yaml so the build is deterministic.
COPY . .
ARG GEWERBER_DEP_REF=main
RUN if [ "$GEWERBER_DEP_REF" != "main" ]; then \
      tee pubspec_overrides.yaml > /dev/null <<EOF; \
      dependency_overrides:
        gewerber_backend_client:
          git:
            url: https://github.com/Gewerber/gewerber-backend.git
            path: gewerber_backend_client
            ref: $GEWERBER_DEP_REF
        gewerber_backend_commercial_client:
          git:
            url: https://github.com/Gewerber/gewerber-backend-stubs.git
            path: gewerber_backend_commercial_client
            ref: $GEWERBER_DEP_REF
      EOF
      echo "pinned inter-repo deps to ref: $GEWERBER_DEP_REF"; \
    fi

# FLAVOR selects the entry point: "prod" uses lib/main.dart (no flavor
# banner), any other value builds lib/main_<flavor>.dart (banner + per-flavor
# defaults).
RUN flutter pub get
ARG FLAVOR=prod
ARG SERVER_HOST=https://api.gewerber.de
RUN if [ "$FLAVOR" = "prod" ]; then \
      flutter build web --release --base-href / --dart-define=SERVER_HOST=$SERVER_HOST; \
    else \
      flutter build web --release --base-href / --dart-define=SERVER_HOST=$SERVER_HOST -t lib/main_${FLAVOR}.dart; \
    fi

# ---- Runtime stage -------------------------------------------------------
# A slim nginx serving the static Flutter Web build. Flutter uses client-side
# routing, so unknown paths fall back to index.html (SPA).
FROM nginx:alpine AS runtime

COPY --from=build /app/build/web/ /usr/share/nginx/html/
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget -q -O /dev/null http://localhost/ || exit 1

# syntax=docker/dockerfile:1

# ---- Build stage ---------------------------------------------------------
# All dependencies are public (backend client and the commercial client stubs
# resolve from GitHub without authentication) — no build secrets required.

FROM ghcr.io/cirruslabs/flutter:stable AS build

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
# FLAVOR selects the entry point: "prod" uses lib/main.dart (no flavor
# banner), any other value builds lib/main_<flavor>.dart (banner + per-flavor
# defaults).
COPY . .
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

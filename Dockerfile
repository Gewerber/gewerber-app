# syntax=docker/dockerfile:1

# ---- Build stage ---------------------------------------------------------
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Resolve dependencies first for better layer caching. `pubspec.lock` is
# gitignored (*.lock), so only the manifest is copied; `flutter pub get`
# generates the lock (and will honor one if it happens to be present).
COPY pubspec.yaml ./
RUN flutter pub get

# Copy the source and build the web app (releases into build/web/).
COPY . .
RUN flutter pub get
RUN flutter build web --release --base-href /

# ---- Runtime stage -------------------------------------------------------
# A slim nginx serving the static Flutter Web build. Flutter uses client-side
# routing, so unknown paths fall back to index.html (SPA).
FROM nginx:alpine AS runtime

COPY --from=build /app/build/web/ /usr/share/nginx/html/
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget -q -O /dev/null http://localhost/ || exit 1

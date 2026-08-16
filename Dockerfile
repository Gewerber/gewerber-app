# syntax=docker/dockerfile:1

# ---- Build stage ---------------------------------------------------------
# BuildKit secret for the private commercial repo token.
# Pass via: docker build --secret id=commercial_token,env=COMMERCIAL_REPO_TOKEN ...
# BuildKit secret for GHCR token (optional, for other private GHCR packages).
# Pass via: docker build --secret id=ghcr_token,env=GHCR_TOKEN ...

FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Resolve dependencies first for better layer caching. `pubspec.lock` is
# gitignored (*.lock), so only the manifest is copied; `flutter pub get`
# generates the lock (and will honor one if it happens to be present).
COPY pubspec.yaml ./

# Configure git to use the commercial repo token for the private commercial repo
# and GHCR token for other GitHub access. Secrets are mounted only for this step
# and the git config is removed afterwards.
RUN --mount=type=secret,id=commercial_token \
    --mount=type=secret,id=ghcr_token \
    mkdir -p ~/.ssh \
    && printf "Host github.com\n  StrictHostKeyChecking no\n  UserKnownHostsFile=/dev/null\n" > ~/.ssh/config \
    && if [ -f /run/secrets/commercial_token ]; then \
      git config --global url."https://x-access-token:$(cat /run/secrets/commercial_token)@github.com/Gewerber/gewerber-backend-commercial.git".insteadOf "ssh://git@github.com/Gewerber/gewerber-backend-commercial.git"; \
    fi \
    && if [ -f /run/secrets/ghcr_token ]; then \
      git config --global url."https://x-access-token:$(cat /run/secrets/ghcr_token)@github.com/".insteadOf "https://github.com/"; \
    fi \
    && flutter pub get \
    && rm -f ~/.gitconfig ~/.ssh/config

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

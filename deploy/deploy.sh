#!/usr/bin/env bash
# Deploys the Gewerber app on the VPS for a given environment.
#
# The GitHub Actions workflow copies this script and `docker-compose.yml` to
# the VPS, then invokes: `bash deploy.sh <env> <image>`.
#
#   env   : prod | test
#   image : full image reference pushed to GHCR by CI
#
# Optional environment variables:
#   GHCR_TOKEN / GHCR_USER  – credentials to pull the (private) image from GHCR
#   TRAEFIK_NETWORK, WEB_ENTRYPOINT, WEBSECURE_ENTRYPOINT, CERT_RESOLVER
#   DEPLOY_DIR              – base directory (default: $HOME/gewerber/<env>)
set -euo pipefail

ENV="${1:?usage: deploy.sh <prod|test> <image>}"
IMAGE="${2:?usage: deploy.sh <prod|test> <image>}"

case "$ENV" in
  prod)
    CONTAINER_NAME="gewerber-app"
    ROUTER_PREFIX="gw-app"
    HOST_RULE='Host(`app.gewerber.de`)'
    ;;
  test)
    CONTAINER_NAME="gewerber-app-test"
    ROUTER_PREFIX="gw-app-test"
    HOST_RULE='Host(`test.app.gewerber.de`)'
    ;;
  *)
    echo "unknown env: $ENV (expected 'prod' or 'test')" >&2
    exit 1
    ;;
esac

TRAEFIK_NETWORK="${TRAEFIK_NETWORK:-web}"
WEB_ENTRYPOINT="${WEB_ENTRYPOINT:-web}"
WEBSECURE_ENTRYPOINT="${WEBSECURE_ENTRYPOINT:-websecure}"
CERT_RESOLVER="${CERT_RESOLVER:-letsencrypt}"
DEPLOY_DIR="${DEPLOY_DIR:-$HOME/gewerber/$ENV}"

# Log in to GHCR if credentials were provided (private image).
if [ -n "${GHCR_TOKEN:-}" ]; then
  echo "${GHCR_TOKEN}" | docker login ghcr.io -u "${GHCR_USER:-gewerber}" --password-stdin
fi

mkdir -p "$DEPLOY_DIR"

# docker-compose.yml is copied next to this script by CI.
cp -f "$(dirname "$0")/docker-compose.yml" "$DEPLOY_DIR/docker-compose.yml"

# Per-environment .env consumed by docker-compose.yml. `HOST_RULE` contains
# literal backticks (Traefik rule syntax); they are written verbatim.
{
  echo "IMAGE=$IMAGE"
  echo "CONTAINER_NAME=$CONTAINER_NAME"
  echo "ROUTER_PREFIX=$ROUTER_PREFIX"
  echo "HOST_RULE=$HOST_RULE"
  echo "TRAEFIK_NETWORK=$TRAEFIK_NETWORK"
  echo "WEB_ENTRYPOINT=$WEB_ENTRYPOINT"
  echo "WEBSECURE_ENTRYPOINT=$WEBSECURE_ENTRYPOINT"
  echo "CERT_RESOLVER=$CERT_RESOLVER"
} > "$DEPLOY_DIR/.env"

cd "$DEPLOY_DIR"
docker compose pull
docker compose up -d --remove-orphans
docker image prune -f

echo "Deployed $ENV ($IMAGE) as '$CONTAINER_NAME' -> $HOST_RULE"
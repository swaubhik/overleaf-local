#!/usr/bin/env bash
# Create an Overleaf user and print their activation link (no SMTP is configured,
# so the link is never emailed -- copy it from the output and send it yourself).
#
# Usage:
#   scripts/create-user.sh user@example.com          # regular user
#   scripts/create-user.sh --admin user@example.com   # admin user

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$TOOLKIT_ROOT"

ADMIN_FLAG=""
if [[ "${1:-}" == "--admin" ]]; then
  ADMIN_FLAG="--admin"
  shift
fi

EMAIL="${1:-}"
if [[ -z "$EMAIL" ]]; then
  echo "Usage: $0 [--admin] <email>" >&2
  exit 1
fi

./bin/docker-compose exec sharelatex /bin/bash --login -c \
  "cd /overleaf/services/web && node modules/server-ce-scripts/scripts/create-user.mjs $ADMIN_FLAG --email='$EMAIL'"

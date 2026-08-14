#!/usr/bin/env bash
# Delete an Overleaf user and all of their projects.
#
# Usage:
#   scripts/delete-user.sh user@example.com

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$TOOLKIT_ROOT"

EMAIL="${1:-}"
if [[ -z "$EMAIL" ]]; then
  echo "Usage: $0 <email>" >&2
  exit 1
fi

read -r -p "This will permanently delete '$EMAIL' and all their projects. Type the email again to confirm: " CONFIRM
if [[ "$CONFIRM" != "$EMAIL" ]]; then
  echo "Confirmation did not match, aborting." >&2
  exit 1
fi

./bin/docker-compose exec sharelatex /bin/bash --login -c \
  "cd /overleaf/services/web && node modules/server-ce-scripts/scripts/delete-user.mjs --skip-email --email='$EMAIL'"

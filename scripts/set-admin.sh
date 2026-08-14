#!/usr/bin/env bash
# Grant or revoke admin rights for an existing Overleaf user.
#
# Usage:
#   scripts/set-admin.sh user@example.com on
#   scripts/set-admin.sh user@example.com off

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$TOOLKIT_ROOT"

EMAIL="${1:-}"
MODE="${2:-}"
if [[ -z "$EMAIL" || ( "$MODE" != "on" && "$MODE" != "off" ) ]]; then
  echo "Usage: $0 <email> <on|off>" >&2
  exit 1
fi

if [[ "$MODE" == "on" ]]; then
  BOOL="true"
else
  BOOL="false"
fi

MONGO_CONTAINER="$(./bin/docker-compose ps -q mongo)"

docker exec "$MONGO_CONTAINER" mongosh sharelatex --quiet --eval "
var res = db.users.updateOne({email: '$EMAIL'}, {\$set: {isAdmin: $BOOL}});
if (res.matchedCount === 0) {
  print('No user found with email $EMAIL');
  quit(1);
}
print('Updated $EMAIL: isAdmin=$BOOL');
"

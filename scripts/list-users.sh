#!/usr/bin/env bash
# List all Overleaf users with email, admin status, and last login.
#
# Usage:
#   scripts/list-users.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$TOOLKIT_ROOT"

MONGO_CONTAINER="$(./bin/docker-compose ps -q mongo)"

docker exec "$MONGO_CONTAINER" mongosh sharelatex --quiet --eval '
db.users.find({}, {email: 1, isAdmin: 1, lastLoggedIn: 1, signUpDate: 1}).forEach(function(u) {
  print(
    (u.email || "(no email)").padEnd(40) +
    (u.isAdmin ? "admin" : "user").padEnd(8) +
    "signed up: " + (u.signUpDate ? u.signUpDate.toISOString() : "-").padEnd(32) +
    "last login: " + (u.lastLoggedIn ? u.lastLoggedIn.toISOString() : "never")
  );
})
'

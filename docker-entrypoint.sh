#!/bin/sh
set -e

echo "Running migrations..."
/app/bin/bowl_site eval "BowlSite.Release.migrate()"

echo "Running seeds (idempotent)..."
/app/bin/bowl_site eval "BowlSite.Release.seed()"

exec "$@"

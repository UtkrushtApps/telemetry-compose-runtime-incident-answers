#!/bin/sh
set -eu

SCRATCH_DIR="${SCRATCH_DIR:-/var/run/telemetry}"
mkdir -p "$SCRATCH_DIR" 2>/dev/null || true
chmod 0777 "$SCRATCH_DIR" 2>/dev/null || true

# Replace shell with the Go process so SIGTERM is delivered directly to it.
exec "$@"

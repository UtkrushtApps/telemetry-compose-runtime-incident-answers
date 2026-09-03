#!/bin/sh
set -eu

DATA_DIR="${DATA_DIR:-/data}"
mkdir -p "$DATA_DIR" 2>/dev/null || true

# Replace shell with the Go process so SIGTERM is delivered directly to it.
exec "$@"

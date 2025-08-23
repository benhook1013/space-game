#!/usr/bin/env bash
set -euo pipefail

# Bootstrap the Flutter SDK so wrapper scripts can use it.
echo "[setup] Bootstrapping Flutter SDK"
"$(dirname "$0")/scripts/bootstrap_flutter.sh"
echo "[setup] Completed"

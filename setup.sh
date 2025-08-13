#!/usr/bin/env bash
set -euo pipefail

# Bootstrap the Flutter SDK so wrapper scripts can use it.
"$(dirname "$0")/scripts/bootstrap_flutter.sh" >/dev/null 2>&1 || true

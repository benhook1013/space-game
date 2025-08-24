#!/usr/bin/env bash
set -euo pipefail
if command -v markdownlint >/dev/null 2>&1; then
  exec markdownlint "$@"
else
  exec npx --yes markdownlint "$@"
fi

#!/usr/bin/env bash
set -euo pipefail
if command -v markdownlint >/dev/null 2>&1; then
  exec markdownlint "$@"
elif command -v npx >/dev/null 2>&1; then
  # Use the markdownlint-cli package when the global binary is missing.
  exec npx --yes markdownlint-cli "$@"
else
  echo "markdownlint and npx are not installed" >&2
  exit 1
fi

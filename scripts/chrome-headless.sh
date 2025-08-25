#!/usr/bin/env bash
set -euo pipefail
if command -v google-chrome >/dev/null 2>&1; then
  browser=google-chrome
elif command -v chromium-browser >/dev/null 2>&1; then
  browser=chromium-browser
elif command -v chromium >/dev/null 2>&1; then
  browser=chromium
else
  echo "Chrome or Chromium not found" >&2
  exit 1
fi
exec xvfb-run -a "$browser" --no-sandbox --disable-dev-shm-usage "$@"

#!/usr/bin/env bash
set -euo pipefail

# === Config ===
: "${FLUTTER_VERSION:=3.32.8}"   # Pin your version here
: "${FLUTTER_CHANNEL:=stable}"   # stable | beta
FLUTTER_DIR=".tooling/flutter"

# Helper: lowercase
lower() { echo "$1" | tr '[:upper:]' '[:lower:]'; }

# If already present, just ensure PATH and exit
if [ -x "$FLUTTER_DIR/bin/flutter" ]; then
  export PATH="$(pwd)/$FLUTTER_DIR/bin:$PATH"
  git config --global --add safe.directory "$(pwd)/$FLUTTER_DIR" 2>/dev/null || true
  # Warm up (non-fatal if doctor shows warnings)
  .tooling/flutter/bin/flutter --version >/dev/null 2>&1 || true
  return 0 2>/dev/null || exit 0
fi

echo "Bootstrapping Flutter $FLUTTER_VERSION ($FLUTTER_CHANNEL)…"
mkdir -p .tooling
pushd .tooling >/dev/null

OS_NAME="$(uname -s)"
case "$OS_NAME" in
  Linux)
    ARCHIVE="flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz"
    OS_SLUG="linux"
    ;;
  Darwin)
    ARCHIVE="flutter_macos_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.zip"
    OS_SLUG="macos"
    ;;
  CYGWIN*|MINGW*|MSYS*)
    echo "Windows bootstrap via bash is not supported here. Use scripts/bootstrap_flutter.ps1."
    exit 1
    ;;
  *)
    echo "Unsupported OS: $OS_NAME"
    exit 1
    ;;
esac

BASE_URL="https://storage.googleapis.com/flutter_infra_release/releases"
URL="${BASE_URL}/${FLUTTER_CHANNEL}/$(lower "$OS_SLUG")/${ARCHIVE}"
echo "Downloading: $URL"
curl -fL "$URL" -o "$ARCHIVE"

echo "Extracting…"
if [[ "$ARCHIVE" == *.tar.xz ]]; then
  tar -xJf "$ARCHIVE"
else
  unzip -q "$ARCHIVE"
fi
rm -f "$ARCHIVE"

popd >/dev/null

# Put Flutter on PATH for this shell
export PATH="$(pwd)/$FLUTTER_DIR/bin:$PATH"
git config --global --add safe.directory "$(pwd)/$FLUTTER_DIR" 2>/dev/null || true

# Non-interactive sanity checks (allow warnings)
.tooling/flutter/bin/flutter --version
.tooling/flutter/bin/flutter config --enable-web || true
.tooling/flutter/bin/flutter doctor -v || true

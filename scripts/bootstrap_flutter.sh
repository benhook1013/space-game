#!/usr/bin/env bash
set -euo pipefail

# === Config ===
: "${FLUTTER_VERSION:=3.32.8}"   # Pin your version here
: "${FLUTTER_CHANNEL:=stable}"   # stable | beta
FLUTTER_DIR=".tooling/flutter"

log() {
  echo "[bootstrap_flutter] $1"
}

# Helper: lowercase
lower() { echo "$1" | tr '[:upper:]' '[:lower:]'; }

log "Ensuring Flutter $FLUTTER_VERSION ($FLUTTER_CHANNEL) in $FLUTTER_DIR"

# If already present, ensure the version/channel match; otherwise upgrade
if [ -x "$FLUTTER_DIR/bin/flutter" ]; then
  log "Existing Flutter installation detected; checking version"
  current_info="$("$FLUTTER_DIR/bin/flutter" --version 2>/dev/null | head -n1 || true)"
  current_version="$(echo "$current_info" | awk '{print $2}')"
  current_channel="$(echo "$current_info" | awk '{print $5}')"
  if [ "$current_version" = "$FLUTTER_VERSION" ] && \
     [ "$current_channel" = "$FLUTTER_CHANNEL" ]; then
    log "Flutter $current_version ($current_channel) already installed"
    export PATH="$(pwd)/$FLUTTER_DIR/bin:$PATH"
    git config --global --add safe.directory "$(pwd)/$FLUTTER_DIR" 2>/dev/null || true
    # Warm up (non-fatal if doctor shows warnings)
    "$FLUTTER_DIR/bin/flutter" --version >/dev/null 2>&1 || true
    return 0 2>/dev/null || exit 0
  else
    log "Flutter $current_version ($current_channel) found, but $FLUTTER_VERSION ($FLUTTER_CHANNEL) required"
    log "Removing old Flutter installation"
    rm -rf "$FLUTTER_DIR"
  fi
else
  log "No Flutter installation found"
fi

log "Bootstrapping Flutter $FLUTTER_VERSION ($FLUTTER_CHANNEL)"
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
log "Downloading: $URL"
curl -fL "$URL" -o "$ARCHIVE"

log "Extracting archive"
if [[ "$ARCHIVE" == *.tar.xz ]]; then
  tar -xJf "$ARCHIVE"
else
  unzip -q "$ARCHIVE"
fi
rm -f "$ARCHIVE"

popd >/dev/null
log "Flutter SDK installed at $FLUTTER_DIR"

# Put Flutter on PATH for this shell
export PATH="$(pwd)/$FLUTTER_DIR/bin:$PATH"
git config --global --add safe.directory "$(pwd)/$FLUTTER_DIR" 2>/dev/null || true

# Non-interactive sanity checks (allow warnings)
log "Running flutter --version"
.tooling/flutter/bin/flutter --version
log "Enabling web support"
.tooling/flutter/bin/flutter config --enable-web || true
log "Running flutter doctor"
.tooling/flutter/bin/flutter doctor -v || true

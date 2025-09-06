#!/usr/bin/env bash
set -euo pipefail

# --------------------------
# Options / env
# --------------------------
WITH_MEDIA_TOOLS="${WITH_MEDIA_TOOLS:-0}"      # 1 to opt-in to ffmpeg/imagemagick
SKIP_DOCTOR="${SKIP_DOCTOR:-1}"                # 1 = skip flutter doctor by default
FLUTTER_VERSION="${FLUTTER_VERSION:-3.32.8}"   # keep in sync with bootstrap
FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"
PROJECT_ROOT="$(pwd)"
FLUTTER_DIR_REL=".tooling/flutter"
FLUTTER_DIR="${PROJECT_ROOT}/${FLUTTER_DIR_REL}"

log() { echo "[setup] $*"; }

# Make Flutter web setup quieter and avoid Chrome checks in CI/Codespaces-type envs
export FLUTTER_WEB_SKIP_CHROME_SETUP="${FLUTTER_WEB_SKIP_CHROME_SETUP:-true}"

# Speed up Dart/Flutter package installs between runs
export PUB_CACHE="${PUB_CACHE:-$PROJECT_ROOT/.tooling/pub-cache}"
mkdir -p "$PUB_CACHE"

# --------------------------
# Bootstrap Flutter (download + extract)
# --------------------------
log "Bootstrapping Flutter SDK"
./bootstrap_flutter.sh

# --------------------------
# Provide an FVM-shaped view without installing FVM
# --------------------------
log "Linking bootstrapped Flutter to .fvm/flutter_sdk"
mkdir -p .fvm
rm -rf .fvm/flutter_sdk
ln -s ../.tooling/flutter .fvm/flutter_sdk

# --------------------------
# Optionally install media tools (guarded)
# --------------------------
if [[ "$WITH_MEDIA_TOOLS" == "1" ]]; then
  log "Installing media tools (ffmpeg, imagemagick)"
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ffmpeg imagemagick
else
  log "Media tools skipped (WITH_MEDIA_TOOLS=0)"
fi

# --------------------------
# Flutter pub get (enforce lockfile if present)
# --------------------------
log "Fetching pub dependencies"
FLUTTER_BIN="$FLUTTER_DIR/bin/flutter"
if [[ -f "pubspec.lock" ]]; then
  "$FLUTTER_BIN" pub get --enforce-lockfile || "$FLUTTER_BIN" pub get
else
  "$FLUTTER_BIN" pub get
fi

log "Persisting env hints"
# Helpful for interactive shells opened later in the same container
{
  echo "export PATH=\"$FLUTTER_DIR/bin:\$PATH\""
  echo "export PUB_CACHE=\"$PUB_CACHE\""
} >> /root/.bashrc || true
{
  echo "export PATH=\"$FLUTTER_DIR/bin:\$PATH\""
  echo "export PUB_CACHE=\"$PUB_CACHE\""
} >> /root/.profile || true

log "Completed"

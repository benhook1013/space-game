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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { echo "[setup] $*"; }

# Make Flutter web setup quieter and avoid Chrome checks in CI/Codespaces-type envs
export FLUTTER_WEB_SKIP_CHROME_SETUP="${FLUTTER_WEB_SKIP_CHROME_SETUP:-true}"

# Speed up Dart/Flutter package installs between runs
export PUB_CACHE="${PUB_CACHE:-$PROJECT_ROOT/.tooling/pub-cache}"
mkdir -p "$PUB_CACHE"

# --------------------------
# Loud env + context logging
# --------------------------
log "Env:"
log "  CI=${CI:-0}"
log "  WITH_MEDIA_TOOLS=${WITH_MEDIA_TOOLS}"
log "  FORCE_MEDIA_TOOLS=${FORCE_MEDIA_TOOLS:-0}"
log "  SKIP_DOCTOR=${SKIP_DOCTOR}"
log "  FLUTTER_VERSION=${FLUTTER_VERSION}"
log "  FLUTTER_CHANNEL=${FLUTTER_CHANNEL}"
log "  FLUTTER_WEB_SKIP_CHROME_SETUP=${FLUTTER_WEB_SKIP_CHROME_SETUP}"
log "  PUB_CACHE=${PUB_CACHE}"
log "Context:"
log "  whoami=$(whoami)  pwd=${PROJECT_ROOT}"
log "  script=${BASH_SOURCE[0]}"
log "  flutter_dir=${FLUTTER_DIR}"

# --------------------------
# Fail-safe guard for media tools
# - Only allow when CI=1 or FORCE_MEDIA_TOOLS=1
# --------------------------
if [[ "${WITH_MEDIA_TOOLS}" == "1" && "${CI:-0}" != "1" && "${FORCE_MEDIA_TOOLS:-0}" != "1" ]]; then
  log "WITH_MEDIA_TOOLS=1 requested, but not in CI and FORCE_MEDIA_TOOLS!=1 -> ignoring (setting to 0)."
  WITH_MEDIA_TOOLS=0
fi

# --------------------------
# Timing helper
# --------------------------
step_start() { STEP_NAME="$1"; STEP_T0="$(date +%s)"; log ">>> ${STEP_NAME}..."; }
step_end()   { local t1; t1="$(date +%s)"; log "<<< ${STEP_NAME} done in $(( t1 - STEP_T0 ))s"; }

# --------------------------
# Bootstrap Flutter (download + extract)
# --------------------------
step_start "Bootstrapping Flutter SDK"
"${SCRIPT_DIR}/scripts/bootstrap_flutter.sh"
step_end

# --------------------------
# Provide an FVM-shaped view without installing FVM
# --------------------------
step_start "Linking bootstrapped Flutter to .fvm/flutter_sdk"
mkdir -p .fvm
rm -rf .fvm/flutter_sdk
ln -s ../.tooling/flutter .fvm/flutter_sdk
step_end

# --------------------------
# Optionally install media tools (guarded)
# --------------------------
if [[ "$WITH_MEDIA_TOOLS" == "1" ]]; then
  step_start "Installing media tools (ffmpeg, imagemagick)"
  log "About to run apt-get install (this is slow and pulls many deps)."
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ffmpeg imagemagick
  step_end
else
  log "Media tools skipped (WITH_MEDIA_TOOLS=0)"
fi

# --------------------------
# Flutter pub get (enforce lockfile if present)
# --------------------------
step_start "Fetching pub dependencies"
FLUTTER_BIN="$FLUTTER_DIR/bin/flutter"
if [[ -f "pubspec.lock" ]]; then
  "$FLUTTER_BIN" pub get --enforce-lockfile || "$FLUTTER_BIN" pub get
else
  "$FLUTTER_BIN" pub get
fi
step_end

# --------------------------
# Persist env hints
# --------------------------
step_start "Persisting env hints"
{
  echo "export PATH=\"$FLUTTER_DIR/bin:\$PATH\""
  echo "export PUB_CACHE=\"$PUB_CACHE\""
} >> /root/.bashrc || true
{
  echo "export PATH=\"$FLUTTER_DIR/bin:\$PATH\""
  echo "export PUB_CACHE=\"$PUB_CACHE\""
} >> /root/.profile || true
step_end

log "Completed"

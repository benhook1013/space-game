#!/usr/bin/env bash
set -euo pipefail

FORCE=false
QUIET=false
DOWNLOADER=http
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=true ;;
    --quiet) QUIET=true ;;
    --downloader) DOWNLOADER="$2"; shift ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

# === Config ===
: "${FLUTTER_VERSION:=3.32.8}"   # Pin your version here
: "${FLUTTER_CHANNEL:=stable}"   # stable | beta
FLUTTER_DIR=".tooling/flutter"

log() {
  if [ "$QUIET" != true ]; then
    echo "[bootstrap_flutter] $1"
  fi
}

# Helper: lowercase
lower() { echo "$1" | tr '[:upper:]' '[:lower:]'; }

log "Ensuring Flutter $FLUTTER_VERSION ($FLUTTER_CHANNEL) in $FLUTTER_DIR"

needs_download=true
if [ -x "$FLUTTER_DIR/bin/flutter" ]; then
  if [ "$FORCE" = true ]; then
    log "Force option set; removing existing Flutter installation"
    rm -rf "$FLUTTER_DIR"
  else
    log "Existing Flutter installation detected; checking version"
    current_info="$("$FLUTTER_DIR/bin/flutter" --version 2>/dev/null | head -n1 || true)"
    current_version="$(echo "$current_info" | awk '{print $2}')"
    current_channel="$(echo "$current_info" | awk '{print $5}')"
    if [ "$current_version" = "$FLUTTER_VERSION" ] && \
       [ "$current_channel" = "$FLUTTER_CHANNEL" ]; then
      log "Flutter $current_version ($current_channel) already installed"
      needs_download=false
    else
      log "Flutter $current_version ($current_channel) found, but $FLUTTER_VERSION ($FLUTTER_CHANNEL) required"
      log "Removing old Flutter installation"
      rm -rf "$FLUTTER_DIR"
    fi
  fi
else
  log "No Flutter installation found"
fi

if [ "$needs_download" = true ]; then
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

  if [ -n "${FLUTTER_DOWNLOAD_MIRROR:-}" ]; then
    BASE_URL="${FLUTTER_DOWNLOAD_MIRROR%/}"
  else
    BASE_URL="https://storage.googleapis.com/flutter_infra_release/releases"
  fi
  URL="${BASE_URL}/${FLUTTER_CHANNEL}/$(lower "$OS_SLUG")/${ARCHIVE}"
  log "Downloading: $URL (downloader=$DOWNLOADER)"

  download_http() {
    local url="$1" dest="$2"
    local tmp="${dest}.partial"
    local opts=(--fail --location --retry 3 --retry-delay 2 --connect-timeout 30)
    if [ "$QUIET" = true ]; then opts+=(--silent --show-error); fi
    if [ -f "$tmp" ]; then opts+=(-C -); fi
    curl "${opts[@]}" "$url" -o "$tmp"
    mv "$tmp" "$dest"
  }

  download_ranges() {
  local url="$1" dest="$2" parts=8
  local len
  len=$(curl -sI "$url" | awk '/Content-Length/ {print $2}' | tr -d '\r')
  if [[ -z "$len" ]]; then
    log "Server did not return length; falling back to single stream"
    download_http "$url" "$dest"
    return
  fi
  local chunk=$(( (len + parts - 1) / parts ))
  local tmpfiles=()
  for ((i=0;i<parts;i++)); do
    local start=$(( i * chunk ))
    local end=$(( start + chunk - 1 ))
    (( start > len - 1 )) && break
    (( end > len - 1 )) && end=$(( len - 1 ))
    local tmp="part-$i"
    tmpfiles+=("$tmp")
    local curl_opts=(--fail --location --retry 3 --retry-delay 2 -r "${start}-${end}")
    if [ "$QUIET" = true ]; then curl_opts+=(--silent --show-error); fi
    curl "${curl_opts[@]}" "$url" -o "$tmp" &
  done
  local start_time
  start_time=$(date +%s)
  while [[ -n "$(jobs -p)" ]]; do
    local size=0
    for f in "${tmpfiles[@]}"; do
      if [ -f "$f" ]; then
        if stat -c%s "$f" >/dev/null 2>&1; then
          size=$(( size + $(stat -c%s "$f") ))
        else
          size=$(( size + $(stat -f%z "$f") ))
        fi
      fi
    done
    local elapsed=$(( $(date +%s) - start_time ))
    (( elapsed == 0 )) && elapsed=1
    local mb_read
    mb_read=$(awk "BEGIN {printf \"%.1f\", $size/1048576}")
    local mb_tot
    mb_tot=$(awk "BEGIN {printf \"%.1f\", $len/1048576}")
    local speed
    speed=$(awk "BEGIN {printf \"%.2f\", ($size/1048576)/$elapsed}")
    local pct=$(( size*100/len ))
    if [ "$QUIET" != true ]; then
      printf "\rDownloading Flutter (ranges): %s/%s MB (%d%%) @ %s MB/s" \
        "$mb_read" "$mb_tot" "$pct" "$speed"
    fi
    sleep 0.2
  done
  wait
  if [ "$QUIET" != true ]; then printf "\n"; fi
  cat "${tmpfiles[@]}" > "$dest"
  rm -f "${tmpfiles[@]}"
  }

  extract_with_progress() {
  python3 - "$1" "$QUIET" <<'PY'
import sys, zipfile, tarfile
archive = sys.argv[1]
quiet = sys.argv[2] == 'true'
dest = '.'
def progress(i, total):
    if quiet: return
    pct = int(i*100/total)
    print(f"\rExtracting Flutter SDK: {i}/{total} ({pct}%)", end="")
if archive.endswith('.tar.xz'):
    with tarfile.open(archive, 'r:xz') as tar:
        members = tar.getmembers()
        total = len(members)
        for i, m in enumerate(members, 1):
            tar.extract(m, path=dest)
            progress(i, total)
else:
    with zipfile.ZipFile(archive) as z:
        infos = z.infolist()
        total = len(infos)
        for i, info in enumerate(infos, 1):
            z.extract(info, path=dest)
            progress(i, total)
if not quiet:
    print()
PY
  }

  dest="$ARCHIVE"
  case "$DOWNLOADER" in
    ranges) download_ranges "$URL" "$dest" ;;
    *)      download_http   "$URL" "$dest" ;;
  esac

  if [ -n "${FLUTTER_SHA256:-}" ]; then
    log "Verifying SHA256"
    actual=$(sha256sum "$dest" | awk '{print $1}')
    if [ "${actual,,}" != "${FLUTTER_SHA256,,}" ]; then
      echo "Checksum mismatch for $ARCHIVE" >&2
      exit 1
    fi
  fi

  extract_with_progress "$dest"
  rm -f "$dest"

  popd >/dev/null
  log "Flutter SDK installed at $FLUTTER_DIR"
fi

PATH="$(pwd)/$FLUTTER_DIR/bin:$PATH"
export PATH
git config --global --add safe.directory "$(pwd)/$FLUTTER_DIR" 2>/dev/null || true

if [ "$needs_download" = true ]; then
  log "Running flutter --version"
  .tooling/flutter/bin/flutter --version || true
  log "Enabling web support"
  .tooling/flutter/bin/flutter config --enable-web || true
  if [ "${SKIP_DOCTOR:-}" != "1" ]; then
    log "Running flutter doctor"
    .tooling/flutter/bin/flutter doctor -v || true
  fi
else
  log "Flutter SDK already installed; skipping flutter doctor"
fi
log "Flutter bootstrap complete"

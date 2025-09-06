#!/usr/bin/env bash
set -euo pipefail

FORCE=false
QUIET=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=true ;;
    --quiet) QUIET=true ;;
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
    if current_info="$("$FLUTTER_DIR/bin/flutter" --version 2>/dev/null | tr '\n' ' ')"; then
      log "flutter --version output: $current_info"
    else
      current_info=""
    fi
    # Try to parse: Flutter <ver> ... channel <chan>
    if [[ "$current_info" =~ Flutter[[:space:]]+([^[:space:]]+).*channel[[:space:]]+([^[:space:]]+) ]]; then
      current_version="${BASH_REMATCH[1]}"
      current_channel="${BASH_REMATCH[2]}"
      log "Parsed installed Flutter: version=$current_version channel=$current_channel"
      if [ "$current_version" = "$FLUTTER_VERSION" ] && [ "$current_channel" = "$FLUTTER_CHANNEL" ]; then
        log "Installed Flutter matches required version/channel"
        needs_download=false
      else
        log "Installed=$current_version ($current_channel); required=$FLUTTER_VERSION ($FLUTTER_CHANNEL). Will (re)install."
        log "Removing old Flutter installation"
        rm -rf "$FLUTTER_DIR"
      fi
    else
      log "Unable to parse Flutter version; will reinstall"
      rm -rf "$FLUTTER_DIR"
    fi
  fi
else
  log "No Flutter installation found"
fi

if [ "$needs_download" = true ]; then
  log "Bootstrapping Flutter $FLUTTER_VERSION ($FLUTTER_CHANNEL)"
  mkdir -p .tooling
  mkdir -p "$FLUTTER_DIR"
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
  log "Downloading: $URL (downloader=http)"

  download_http() {
    local url="$1" dest="$2"
    local tmp="${dest}.partial"
    local opts=(--fail --location --retry 3 --retry-delay 2 --connect-timeout 30)
    if [ "$QUIET" = true ]; then opts+=(--silent --show-error); fi
    if [ -f "$tmp" ]; then opts+=(-C -); fi
    curl "${opts[@]}" "$url" -o "$tmp"
    mv "$tmp" "$dest"
  }


  extract_with_progress() {
  python3 - "$1" "$2" "$QUIET" <<'PY'
import sys, zipfile, tarfile
archive = sys.argv[1]
dest = sys.argv[2]
quiet = sys.argv[3] == 'true'
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
  # Reuse existing archive if present and checksum matches (if provided)
  if [ -f "$dest" ] && [ -n "${FLUTTER_SHA256:-}" ]; then
    log "Existing archive found; verifying SHA256"
    actual=$(sha256sum "$dest" | awk '{print $1}')
    if [ "${actual,,}" = "${FLUTTER_SHA256,,}" ]; then
      log "Existing archive checksum OK; reusing download"
      reuse=true
    else
      log "Existing archive checksum mismatch (actual=$actual); re-downloading"
      rm -f "$dest"
      reuse=false
    fi
  elif [ -f "$dest" ]; then
    log "Existing archive found; reusing download (no checksum configured)"
    reuse=true
  else
    reuse=false
  fi

  if [ "$reuse" != true ]; then
    # Clean stale artifacts before a fresh download
    rm -f "$dest" "$dest.partial"
    rm -rf "$FLUTTER_DIR" "_extract_flutter_tmp"
    download_http "$URL" "$dest"
  fi

  if [ -n "${FLUTTER_SHA256:-}" ]; then
    log "Verifying SHA256"
    actual=$(sha256sum "$dest" | awk '{print $1}')
    if [ "${actual,,}" != "${FLUTTER_SHA256,,}" ]; then
      echo "Checksum mismatch for $ARCHIVE" >&2
      exit 1
    fi
  fi

  # Extract to temp dir and move atomically into place
  tmpdir="_extract_flutter_tmp"
  rm -rf "$tmpdir" && mkdir -p "$tmpdir"
  extract_with_progress "$dest" "$tmpdir"
  if [ -d "$tmpdir/flutter" ]; then
    rm -rf "$FLUTTER_DIR"
    mkdir -p "$FLUTTER_DIR"
    mv "$tmpdir/flutter" "$FLUTTER_DIR"
  else
    echo "Extracted archive missing 'flutter' directory" >&2
    rm -rf "$tmpdir"
    exit 1
  fi
  rm -rf "$tmpdir"
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

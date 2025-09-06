#!/usr/bin/env bash
set -euo pipefail

# --------------------------
# Flags
# --------------------------
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

# --------------------------
# Config
# --------------------------
: "${FLUTTER_VERSION:=3.32.8}"   # Pin your version here
: "${FLUTTER_CHANNEL:=stable}"   # stable | beta
: "${FLUTTER_DOWNLOAD_MIRROR:=https://storage.googleapis.com/flutter_infra_release}"

ROOT_DIR="$(pwd)"
FLUTTER_DIR_REL=".tooling/flutter"
FLUTTER_DIR="${ROOT_DIR}/${FLUTTER_DIR_REL}"
FLUTTER_PARENT="$(dirname "$FLUTTER_DIR")"
CACHE_DIR="${FLUTTER_PARENT}/cache"
mkdir -p "$FLUTTER_PARENT" "$CACHE_DIR"

log() { if [ "$QUIET" != true ]; then echo "[bootstrap_flutter] $*"; fi; }
lower() { echo "$1" | tr '[:upper:]' '[:lower:]'; }

log "Ensuring Flutter $FLUTTER_VERSION ($FLUTTER_CHANNEL) in $FLUTTER_DIR_REL"

# --------------------------
# Early exit if we already have the right SDK
# --------------------------
needs_download=true
if [[ -x "$FLUTTER_DIR/bin/flutter" && "$FORCE" != true ]]; then
  current_info="$("$FLUTTER_DIR/bin/flutter" --version 2>/dev/null | tr '\n' ' ' || true)"
  if [[ "$current_info" =~ Flutter[[:space:]]+([^[:space:]]+).*channel[[:space:]]+([^[:space:]]+) ]]; then
    current_version="${BASH_REMATCH[1]}"
    current_channel="${BASH_REMATCH[2]}"
    if [[ "$current_version" == "$FLUTTER_VERSION" && "$current_channel" == "$FLUTTER_CHANNEL" ]]; then
      log "Flutter $current_version ($current_channel) already installed"
      needs_download=false
    else
      log "Found $current_version ($current_channel) but need $FLUTTER_VERSION ($FLUTTER_CHANNEL); will reinstall"
      rm -rf "$FLUTTER_DIR"
    fi
  else
    log "Unable to parse existing Flutter; will reinstall"
    rm -rf "$FLUTTER_DIR"
  fi
elif [[ "$FORCE" == true ]]; then
  log "Force requested; removing any existing Flutter"
  rm -rf "$FLUTTER_DIR"
fi

# --------------------------
# Download + extract
# --------------------------
if [[ "$needs_download" == true ]]; then
  OS_NAME="$(uname -s)"
  case "$OS_NAME" in
    Linux)  ARCHIVE="flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz"; OS_SLUG="linux" ;;
    Darwin) ARCHIVE="flutter_macos_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.zip";    OS_SLUG="macos" ;;
    CYGWIN*|MINGW*|MSYS*) echo "Use scripts/bootstrap_flutter.ps1 on Windows"; exit 1 ;;
    *) echo "Unsupported OS: $OS_NAME" >&2; exit 1 ;;
  esac

  BASE_URL="${FLUTTER_DOWNLOAD_MIRROR%/}"
  URL="${BASE_URL}/${FLUTTER_CHANNEL}/$(lower "$OS_SLUG")/${ARCHIVE}"
  DEST="${CACHE_DIR}/${ARCHIVE}"

  log "Downloading: $URL (downloader=$DOWNLOADER)"

  download_http() {
    local url="$1" dest="$2"
    local tmp="${dest}.partial"
    local opts=(--fail --location --retry 3 --retry-delay 2 --connect-timeout 30)
    if [[ "$QUIET" == true ]]; then opts+=(--silent --show-error); fi
    if [[ -f "$tmp" ]]; then opts+=(-C -); fi
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
      local tmp="${dest}.part-$i"
      tmpfiles+=("$tmp")
      local curl_opts=(--fail --location --retry 3 --retry-delay 2 -r "${start}-${end}")
      if [[ "$QUIET" == true ]]; then curl_opts+=(--silent --show-error); fi
      curl "${curl_opts[@]}" "$url" -o "$tmp" &
    done
    wait
    cat "${tmpfiles[@]}" > "$dest"
    rm -f "${tmpfiles[@]}"
  }

  # reuse existing archive if present unless --force
  if [[ ! -f "$DEST" || "$FORCE" == true ]]; then
    rm -f "$DEST" "${DEST}.partial"
    case "$DOWNLOADER" in
      ranges) download_ranges "$URL" "$DEST" ;;
      *)      download_http   "$URL" "$DEST" ;;
    esac
  else
    log "Reusing cached archive: ${DEST##*/}"
  fi

  # Extract with native tools (faster than Python tarfile/zipfile)
  rm -rf "${FLUTTER_DIR}" "${FLUTTER_PARENT}/_extract_flutter_tmp"
  mkdir -p "${FLUTTER_PARENT}/_extract_flutter_tmp"
  if [[ "$DEST" == *.tar.xz ]]; then
    (cd "${FLUTTER_PARENT}/_extract_flutter_tmp" && tar -xJf "$DEST")
  else
    (cd "${FLUTTER_PARENT}/_extract_flutter_tmp" && unzip -q "$DEST")
  fi

  if [[ -d "${FLUTTER_PARENT}/_extract_flutter_tmp/flutter" ]]; then
    mv "${FLUTTER_PARENT}/_extract_flutter_tmp/flutter" "$FLUTTER_DIR"
  else
    echo "Extracted archive missing 'flutter' directory" >&2
    rm -rf "${FLUTTER_PARENT}/_extract_flutter_tmp"
    exit 1
  fi

  rm -rf "${FLUTTER_PARENT}/_extract_flutter_tmp"
  # Keep archive in cache for next runs unless FORCE was set
  if [[ "$FORCE" == true ]]; then rm -f "$DEST"; fi

  log "Flutter SDK installed at $FLUTTER_DIR_REL"
fi

# --------------------------
# Post-install
# --------------------------
export PATH="$FLUTTER_DIR/bin:$PATH"
git config --global --add safe.directory "$FLUTTER_DIR" 2>/dev/null || true

log "Running flutter --version"
"$FLUTTER_DIR/bin/flutter" --version || true

log "Enabling web support"
"$FLUTTER_DIR/bin/flutter" config --enable-web || true

if [[ "${SKIP_DOCTOR:-1}" != "1" ]]; then
  log "Running flutter doctor"
  "$FLUTTER_DIR/bin/flutter" doctor -v || true
else
  log "Skipping flutter doctor (SKIP_DOCTOR=${SKIP_DOCTOR:-1})"
fi

log "Flutter bootstrap complete"

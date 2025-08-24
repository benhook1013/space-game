#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

log() { echo "[setup] $1"; }

# Use sudo when available and needed.
SUDO=""
if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
fi

log "Bootstrapping Flutter SDK"
source "$REPO_ROOT/scripts/bootstrap_flutter.sh"

# Add pub global binaries to PATH and persist for future shells.
PUB_CACHE_BIN="$HOME/.pub-cache/bin"
FLUTTER_BIN="$REPO_ROOT/.tooling/flutter/bin"

add_path() {
  local bin_path="$1"
  if [[ ":$PATH:" != *":$bin_path:"* ]]; then
    export PATH="$bin_path:$PATH"
  fi
  for profile in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    if [ -w "$profile" ] && ! grep -Fqs "$bin_path" "$profile"; then
      printf '\nexport PATH="%s:$PATH"\n' "$bin_path" >> "$profile"
      log "Added $bin_path to PATH in $profile"
    fi
  done
}

add_path "$PUB_CACHE_BIN"
add_path "$FLUTTER_BIN"

# Use repo-local cache for FVM.
export FVM_HOME="$REPO_ROOT/.fvm"
mkdir -p "$FVM_HOME"

# Install FVM if missing.
if ! command -v fvm >/dev/null 2>&1; then
  log "Installing FVM"
  dart pub global activate fvm
fi

# Ensure the pinned Flutter SDK is available for FVM users.
if command -v fvm >/dev/null 2>&1 && [ -f "$REPO_ROOT/fvm_config.json" ]; then
  log "Running fvm install"
  fvm install || log "fvm install failed"
fi

# Install markdownlint CLI if npm exists and it's not already installed.
if ! command -v markdownlint >/dev/null 2>&1; then
  if command -v npm >/dev/null 2>&1; then
    log "Installing markdownlint-cli"
    $SUDO npm install -g markdownlint-cli || log "Failed to install markdownlint-cli"
  else
    log "npm not found; markdownlint will run via npx"
  fi
fi

# Ensure a Chrome-compatible browser exists for Flutter web runs.
if ! command -v google-chrome >/dev/null 2>&1 && \
   ! command -v chromium-browser >/dev/null 2>&1 && \
   ! command -v chromium >/dev/null 2>&1; then
  log "Installing Chromium/Chrome"
  case "$(uname -s)" in
    Linux*)
      if command -v snap >/dev/null 2>&1; then
        $SUDO snap install chromium || log "snap install chromium failed"
      fi
      if ! command -v chromium-browser >/dev/null 2>&1 && \
         ! command -v chromium >/dev/null 2>&1; then
        if command -v apt-get >/dev/null 2>&1; then
          $SUDO apt-get update || true
          $SUDO apt-get install -y chromium-browser || $SUDO apt-get install -y chromium || true
        fi
      fi
      if ! command -v chromium-browser >/dev/null 2>&1 && \
         ! command -v chromium >/dev/null 2>&1; then
        log "Attempting to install Google Chrome"
        if command -v apt-get >/dev/null 2>&1; then
          wget -qO /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
          $SUDO apt-get install -y /tmp/google-chrome.deb || log "Google Chrome install failed"
        fi
      fi
      ;;
    Darwin*)
      if command -v brew >/dev/null 2>&1; then
        brew install --cask google-chrome || log "brew install google-chrome failed"
      fi
      ;;
    *)
      log "Skipping Chrome install: unsupported OS"
      ;;
  esac
fi

# Set CHROME_EXECUTABLE to the resolved browser path.
chrome_path="$(command -v google-chrome 2>/dev/null || command -v chromium-browser 2>/dev/null || command -v chromium 2>/dev/null || true)"
if [ -n "$chrome_path" ]; then
  export CHROME_EXECUTABLE="$chrome_path"
  for profile in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    if [ -w "$profile" ] && ! grep -q "CHROME_EXECUTABLE" "$profile"; then
      printf '\nexport CHROME_EXECUTABLE="%s"\n' "$chrome_path" >> "$profile"
      log "Set CHROME_EXECUTABLE=$chrome_path in $profile"
    fi
  done
fi

log "Completed"

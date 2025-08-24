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

# Ensure Dart/Flutter dependencies are fetched.
log "Fetching pub dependencies"
dart pub get || log "dart pub get failed"

# Use repo-local cache for FVM (FVM_HOME is deprecated).
unset FVM_HOME 2>/dev/null || true
export FVM_CACHE_PATH="$REPO_ROOT/.fvm"
mkdir -p "$FVM_CACHE_PATH"

# Install FVM if missing.
if ! command -v fvm >/dev/null 2>&1; then
  log "Installing FVM"
  dart pub global activate fvm
fi

# Ensure the pinned Flutter SDK is available for FVM users.
if command -v fvm >/dev/null 2>&1 && [ -f "$REPO_ROOT/fvm_config.json" ]; then
  log "Running fvm install"
  if ! fvm install; then
    if command -v jq >/dev/null 2>&1; then
      version="$(jq -r '.flutterSdkVersion' "$REPO_ROOT/fvm_config.json")"
    else
      version="$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+' "$REPO_ROOT/fvm_config.json" | head -n1)"
    fi
    log "fvm install failed; removing existing version $version"
    fvm remove "$version" || true
    rm -rf "$FVM_CACHE_PATH/versions/$version"
    fvm install || log "fvm install failed"
  fi
fi

# Ensure Node.js is available for tooling such as markdownlint.
if ! command -v npm >/dev/null 2>&1; then
  log "npm not found; attempting to install Node.js"
  case "$(uname -s)" in
    Linux*)
      if command -v apt-get >/dev/null 2>&1; then
        $SUDO apt-get update || true
        $SUDO apt-get install -y nodejs npm || log "Failed to install Node.js via apt-get"
      elif command -v snap >/dev/null 2>&1; then
        $SUDO snap install node --classic || log "Failed to install Node.js via snap"
      else
        log "Skipping Node.js install: no supported package manager found"
      fi
      ;;
    Darwin*)
      if command -v brew >/dev/null 2>&1; then
        brew install node || log "brew install node failed"
      else
        log "Skipping Node.js install: brew not found"
      fi
      ;;
    *)
      log "Skipping Node.js install: unsupported OS"
      ;;
  esac
fi

# Install markdownlint CLI if npm is available and the binary is missing.
if ! command -v markdownlint >/dev/null 2>&1; then
  if command -v npm >/dev/null 2>&1; then
    log "Installing markdownlint-cli"
    $SUDO npm install -g markdownlint-cli || log "Failed to install markdownlint-cli"
  else
    log "npm not found; markdownlint will run via npx if available"
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

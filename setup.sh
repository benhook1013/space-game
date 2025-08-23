#!/usr/bin/env bash
set -euo pipefail

# Bootstrap the Flutter SDK so wrapper scripts can use it.
echo "[setup] Bootstrapping Flutter SDK"
source "$(dirname "$0")/scripts/bootstrap_flutter.sh"

# Add pub global binaries to PATH and persist for future shells.
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
PUB_CACHE_BIN="$HOME/.pub-cache/bin"
FLUTTER_BIN="$REPO_ROOT/.tooling/flutter/bin"
if [[ ":$PATH:" != *":$PUB_CACHE_BIN:"* ]]; then
  export PATH="$PUB_CACHE_BIN:$PATH"
fi
if [[ ":$PATH:" != *":$FLUTTER_BIN:"* ]]; then
  export PATH="$FLUTTER_BIN:$PATH"
fi
shell_profile="$HOME/.bashrc"
if [ -w "$shell_profile" ]; then
  if ! grep -q "$PUB_CACHE_BIN" "$shell_profile" 2>/dev/null; then
    printf '\nexport PATH="%s:$PATH"\n' "$PUB_CACHE_BIN" >> "$shell_profile"
    echo "[setup] Added $PUB_CACHE_BIN to PATH in $shell_profile"
  fi
  if ! grep -q "$FLUTTER_BIN" "$shell_profile" 2>/dev/null; then
    printf '\nexport PATH="%s:$PATH"\n' "$FLUTTER_BIN" >> "$shell_profile"
    echo "[setup] Added $FLUTTER_BIN to PATH in $shell_profile"
  fi
fi

# Install FVM (Flutter Version Manager) if it isn't available.
if ! command -v fvm >/dev/null 2>&1; then
  echo "[setup] Installing FVM"
  dart pub global activate fvm >/dev/null
fi

# Install markdownlint CLI for Markdown linting if missing.
if ! command -v markdownlint >/dev/null 2>&1; then
  echo "[setup] Installing markdownlint-cli"
  npm install -g markdownlint-cli >/dev/null 2>&1 || echo "[setup] Failed to install markdownlint-cli"
fi

# Ensure a Chrome-compatible browser exists for Flutter web runs.
if ! command -v google-chrome >/dev/null 2>&1 && \
   ! command -v chromium-browser >/dev/null 2>&1 && \
   ! command -v chromium >/dev/null 2>&1; then
  echo "[setup] Installing Chromium"
  case "$(uname -s)" in
    Linux*)
      if command -v apt-get >/dev/null 2>&1; then
        apt-get update || true
        apt-get install -y chromium-browser || apt-get install -y chromium || true
      fi
      ;;
    Darwin*)
      if command -v brew >/dev/null 2>&1; then
        brew install --cask google-chrome || true
      fi
      ;;
    *)
      echo "[setup] Skipping Chrome install: unsupported OS"
      ;;
  esac
fi

echo "[setup] Completed"

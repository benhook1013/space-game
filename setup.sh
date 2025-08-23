#!/usr/bin/env bash
set -euo pipefail

# Bootstrap the Flutter SDK so wrapper scripts can use it.
echo "[setup] Bootstrapping Flutter SDK"
source "$(dirname "$0")/scripts/bootstrap_flutter.sh"

# Install FVM (Flutter Version Manager) if it isn't available.
if ! command -v fvm >/dev/null 2>&1; then
  echo "[setup] Installing FVM"
  dart pub global activate fvm >/dev/null
fi
# Add pub global binaries to PATH for the current shell.
export PATH="$HOME/.pub-cache/bin:$PATH"

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

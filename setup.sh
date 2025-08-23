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

# Ensure the pinned Flutter SDK is available for FVM users.
if command -v fvm >/dev/null 2>&1 && [ -f "$REPO_ROOT/fvm_config.json" ]; then
  echo "[setup] Running fvm install"
  fvm install >/dev/null 2>&1 || echo "[setup] fvm install failed"
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

# Set CHROME_EXECUTABLE so Flutter can find Chromium when Google Chrome isn't installed.
if ! command -v google-chrome >/dev/null 2>&1; then
  if command -v chromium-browser >/dev/null 2>&1; then
    export CHROME_EXECUTABLE=chromium-browser
    if [ -w "$shell_profile" ] && ! grep -q "CHROME_EXECUTABLE" "$shell_profile" 2>/dev/null; then
      printf '\nexport CHROME_EXECUTABLE=chromium-browser\n' >> "$shell_profile"
      echo "[setup] Set CHROME_EXECUTABLE=chromium-browser in $shell_profile"
    fi
  elif command -v chromium >/dev/null 2>&1; then
    export CHROME_EXECUTABLE=chromium
    if [ -w "$shell_profile" ] && ! grep -q "CHROME_EXECUTABLE" "$shell_profile" 2>/dev/null; then
      printf '\nexport CHROME_EXECUTABLE=chromium\n' >> "$shell_profile"
      echo "[setup] Set CHROME_EXECUTABLE=chromium in $shell_profile"
    fi
  fi
fi

echo "[setup] Completed"

#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
FLUTTER_BIN="$REPO_ROOT/.tooling/flutter/bin"

export PUB_CACHE="${PUB_CACHE:-$HOME/.pub-cache}"
export PATH="$PUB_CACHE/bin:$FLUTTER_BIN:$PATH"

if [ -x "$FLUTTER_BIN/flutter" ] && [ -f "$REPO_ROOT/.dart_tool/package_config.json" ]; then
  echo "setup: already bootstrapped"
  exit 0
fi

log() { echo "[setup] $1"; }

: "${SKIP_DOCTOR:=${CI:+1}}"
: "${SKIP_FVM:=${CI:+1}}"
: "${SKIP_LINT_TOOLS:=${CI:+1}}"
: "${SKIP_MEDIA_TOOLS:=${CI:+1}}"

SUDO=""
if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
fi

log "Bootstrapping Flutter SDK"
bash "$REPO_ROOT/scripts/bootstrap_flutter.sh"

log "Fetching pub dependencies"
"$FLUTTER_BIN/dart" pub get || log "dart pub get failed"

if [ "${SKIP_FVM}" != "1" ]; then
  export FVM_HOME="$REPO_ROOT/.fvm"
  export FVM_CACHE_PATH="$REPO_ROOT/.fvm_cache"
  mkdir -p "$FVM_HOME" "$FVM_CACHE_PATH"
  for profile in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    if [ -w "$profile" ] && ! grep -Fqs "FVM_HOME" "$profile"; then
      printf '\nexport FVM_HOME="%s"\nexport FVM_CACHE_PATH="%s"\n' \
        "$FVM_HOME" "$FVM_CACHE_PATH" >> "$profile"
      log "Persisted FVM env vars in $profile"
    fi
  done
  if ! command -v fvm >/dev/null 2>&1; then
    log "Installing FVM"
    "$FLUTTER_BIN/dart" pub global activate fvm
  fi
  if command -v fvm >/dev/null 2>&1 && [ -f "$REPO_ROOT/fvm_config.json" ]; then
    if command -v jq >/dev/null 2>&1; then
      version="$(jq -r '.flutterSdkVersion' "$REPO_ROOT/fvm_config.json")"
    else
      version="$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+' "$REPO_ROOT/fvm_config.json" | head -n1)"
    fi
    version_dir="$FVM_HOME/versions/$version"
    if [ -e "$version_dir" ] && [ ! -d "$version_dir/.git" ]; then
      log "Removing corrupt FVM version $version"
      rm -rf "$version_dir"
    fi
    if [ ! -e "$version_dir" ]; then
      log "Linking bootstrapped Flutter to FVM version $version"
      mkdir -p "$(dirname "$version_dir")"
      ln -s "$REPO_ROOT/.tooling/flutter" "$version_dir" 2>/dev/null || \
        cp -R "$REPO_ROOT/.tooling/flutter" "$version_dir"
    fi
    if ! fvm --no-print-path flutter --version >/dev/null 2>&1; then
      log "Running fvm install"
      fvm install || log "fvm install failed"
    else
      log "FVM version $version ready"
    fi
  fi
fi

if [ "${SKIP_MEDIA_TOOLS}" != "1" ]; then
  missing_pkgs=()
  command -v convert >/dev/null 2>&1 || missing_pkgs+=(imagemagick)
  command -v ffmpeg >/dev/null 2>&1 || missing_pkgs+=(ffmpeg)
  if [ ${#missing_pkgs[@]} -gt 0 ]; then
    log "Installing missing packages: ${missing_pkgs[*]}"
    case "$(uname -s)" in
      Linux*)
        if command -v apt-get >/dev/null 2>&1; then
          $SUDO apt-get update -y || true
          $SUDO apt-get install -y --no-install-recommends "${missing_pkgs[@]}" || \
            log "Failed to install ${missing_pkgs[*]}"
        fi
        ;;
      Darwin*)
        if command -v brew >/dev/null 2>&1; then
          for pkg in "${missing_pkgs[@]}"; do
            brew install "$pkg" || log "brew install $pkg failed"
          done
        fi
        ;;
    esac
  fi
fi

log "Completed"

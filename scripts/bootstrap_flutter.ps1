#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# === Config ===
$FLUTTER_VERSION = if ($env:FLUTTER_VERSION) { $env:FLUTTER_VERSION } else { '3.32.8' }
$FLUTTER_CHANNEL = if ($env:FLUTTER_CHANNEL) { $env:FLUTTER_CHANNEL } else { 'stable' }
$FLUTTER_DIR = '.tooling/flutter'

# If already present, just ensure PATH and exit
if (Test-Path "$FLUTTER_DIR/bin/flutter.bat") {
    $env:PATH = (Resolve-Path "$FLUTTER_DIR/bin").Path + ";" + $env:PATH
    try { git config --global --add safe.directory (Resolve-Path "$FLUTTER_DIR").Path } catch {}
    try {
        & "$FLUTTER_DIR/bin/flutter.bat" --version | Out-Null
    } catch {}
    return
}

Write-Host "Bootstrapping Flutter $FLUTTER_VERSION ($FLUTTER_CHANNEL)…"
New-Item -ItemType Directory -Force -Path '.tooling' | Out-Null
Push-Location '.tooling'

$ARCHIVE = "flutter_windows_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.zip"
$BASE_URL = 'https://storage.googleapis.com/flutter_infra_release/releases'
$URL = "$BASE_URL/$FLUTTER_CHANNEL/windows/$ARCHIVE"
Write-Host "Downloading: $URL"
Invoke-WebRequest -Uri $URL -OutFile $ARCHIVE

Write-Host 'Extracting…'
Expand-Archive -Path $ARCHIVE -DestinationPath '.' -Force
Remove-Item $ARCHIVE

Pop-Location

# Put Flutter on PATH for this session
$env:PATH = (Resolve-Path "$FLUTTER_DIR/bin").Path + ";" + $env:PATH
try { git config --global --add safe.directory (Resolve-Path "$FLUTTER_DIR").Path } catch {}

# Non-interactive sanity checks (allow warnings)
& "$FLUTTER_DIR/bin/flutter.bat" --version
try { & "$FLUTTER_DIR/bin/flutter.bat" config --enable-web | Out-Null } catch {}
try { & "$FLUTTER_DIR/bin/flutter.bat" doctor -v } catch {}

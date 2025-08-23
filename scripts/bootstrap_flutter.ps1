#!/usr/bin/env pwsh
[CmdletBinding()]
param(
  [switch]$Force,
  [switch]$Quiet
)

function Say([string]$Message) {
  if (-not $Quiet) { Write-Host $Message }
}

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# === Config ===
$FLUTTER_VERSION = if ($env:FLUTTER_VERSION) { $env:FLUTTER_VERSION } else { '3.32.8' }
$FLUTTER_CHANNEL = if ($env:FLUTTER_CHANNEL) { $env:FLUTTER_CHANNEL } else { 'stable' }
$FLUTTER_DIR = '.tooling/flutter'

$flutterBinDir = Join-Path $FLUTTER_DIR 'bin'
try { $flutterBinDir = (Resolve-Path $flutterBinDir).Path } catch {}
$flutterBat    = Join-Path $flutterBinDir 'flutter.bat'

# If already present, just ensure PATH and exit
if ((Test-Path $flutterBat) -and -not $Force) {
  $env:PATH = "$flutterBinDir;$env:PATH"
  try { git config --global --add safe.directory (Resolve-Path "$FLUTTER_DIR").Path } catch {}
  Say "Flutter already present at: $flutterBat"
  & $flutterBat --version
  return
}

Say "Bootstrapping Flutter $FLUTTER_VERSION ($FLUTTER_CHANNEL)…"
New-Item -ItemType Directory -Force -Path '.tooling' | Out-Null
Push-Location '.tooling'

$ARCHIVE = "flutter_windows_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.zip"
$BASE_URL = 'https://storage.googleapis.com/flutter_infra_release/releases'
$URL = "$BASE_URL/$FLUTTER_CHANNEL/windows/$ARCHIVE"
Say "Downloading: $URL"
Invoke-WebRequest -Uri $URL -OutFile $ARCHIVE

Say 'Extracting…'
Expand-Archive -Path $ARCHIVE -DestinationPath '.' -Force
Remove-Item $ARCHIVE

Pop-Location

# Put Flutter on PATH for this session
$flutterBinDir = (Resolve-Path "$FLUTTER_DIR/bin").Path
$flutterBat    = Join-Path $flutterBinDir 'flutter.bat'
$env:PATH = "$flutterBinDir;$env:PATH"
try { git config --global --add safe.directory (Resolve-Path "$FLUTTER_DIR").Path } catch {}

# Non-interactive sanity checks (allow warnings)
& $flutterBat --version
try { & $flutterBat config --enable-web | Out-Null } catch {}
try { & $flutterBat doctor -v } catch {}

#!/usr/bin/env pwsh
[CmdletBinding()]
param(
  [switch]$Force,
  [switch]$Quiet
)

function Say([string]$Message) {
  if (-not $Quiet) { Write-Host "[bootstrap_flutter] $Message" }
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

Say "Ensuring Flutter $FLUTTER_VERSION ($FLUTTER_CHANNEL) in $FLUTTER_DIR"

# If already present, ensure version/channel match; otherwise upgrade
if ((Test-Path $flutterBat) -and -not $Force) {
  Say "Existing Flutter installation detected; checking version"
  $versionOutput = & $flutterBat --version
  if ($versionOutput -match 'Flutter\s+([^\s]+)\s+•\s+channel\s+([^\s]+)') {
    $currentVersion = $matches[1]
    $currentChannel = $matches[2]
  }
  if (($currentVersion -eq $FLUTTER_VERSION) -and ($currentChannel -eq $FLUTTER_CHANNEL)) {
    Say "Flutter $currentVersion ($currentChannel) already installed"
    $env:PATH = "$flutterBinDir;$env:PATH"
    try { git config --global --add safe.directory (Resolve-Path "$FLUTTER_DIR").Path } catch {}
    Say $versionOutput
    return
  } else {
    Say "Flutter $currentVersion ($currentChannel) found, but $FLUTTER_VERSION ($FLUTTER_CHANNEL) required"
    Say "Removing old Flutter installation"
    Remove-Item $FLUTTER_DIR -Recurse -Force
  }
} else {
  Say "No Flutter installation found"
}

Say "Bootstrapping Flutter $FLUTTER_VERSION ($FLUTTER_CHANNEL)"
New-Item -ItemType Directory -Force -Path '.tooling' | Out-Null
Push-Location '.tooling'

$ARCHIVE = "flutter_windows_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.zip"
$BASE_URL = 'https://storage.googleapis.com/flutter_infra_release/releases'
$URL = "$BASE_URL/$FLUTTER_CHANNEL/windows/$ARCHIVE"
Say "Downloading: $URL"
Invoke-WebRequest -Uri $URL -OutFile $ARCHIVE

Say 'Extracting archive'
Expand-Archive -Path $ARCHIVE -DestinationPath '.' -Force
Remove-Item $ARCHIVE

Pop-Location
Say "Flutter SDK installed at $FLUTTER_DIR"

# Put Flutter on PATH for this session
$flutterBinDir = (Resolve-Path "$FLUTTER_DIR/bin").Path
$flutterBat    = Join-Path $flutterBinDir 'flutter.bat'
$env:PATH = "$flutterBinDir;$env:PATH"
try { git config --global --add safe.directory (Resolve-Path "$FLUTTER_DIR").Path } catch {}

# Non-interactive sanity checks (allow warnings)
Say 'Running flutter --version'
& $flutterBat --version
Say 'Enabling web support'
try { & $flutterBat config --enable-web | Out-Null } catch {}
Say 'Running flutter doctor'
try { & $flutterBat doctor -v } catch {}

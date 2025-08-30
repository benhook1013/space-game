#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Push-Location $PSScriptRoot
try {
Write-Host "[setup] Bootstrapping Flutter SDK"
& "$PSScriptRoot/scripts/bootstrap_flutter.ps1"

$repoRoot = Resolve-Path $PSScriptRoot
$pubCacheBin = Join-Path $HOME '.pub-cache/bin'
$flutterBin = Join-Path $repoRoot '.tooling/flutter/bin'

# Use repo-local cache for FVM.
$env:FVM_HOME = Join-Path $repoRoot '.fvm'
New-Item -ItemType Directory -Path $env:FVM_HOME -Force | Out-Null

if ($env:PATH -notlike "*${pubCacheBin}*") {
  $env:PATH = "$pubCacheBin;$env:PATH"
}
if ($env:PATH -notlike "*${flutterBin}*") {
  $env:PATH = "$flutterBin;$env:PATH"
}

$shellProfile = $PROFILE
if (-not (Test-Path $shellProfile)) {
  New-Item -ItemType File -Path $shellProfile -Force | Out-Null
}
if (-not (Get-Content $shellProfile | Select-String ([regex]::Escape($pubCacheBin)) -Quiet)) {
  Add-Content $shellProfile "`n" + '$env:PATH = "' + $pubCacheBin + ';$env:PATH"'
  Write-Host "[setup] Added $pubCacheBin to PATH in $shellProfile"
}
if (-not (Get-Content $shellProfile | Select-String ([regex]::Escape($flutterBin)) -Quiet)) {
  Add-Content $shellProfile "`n" + '$env:PATH = "' + $flutterBin + ';$env:PATH"'
  Write-Host "[setup] Added $flutterBin to PATH in $shellProfile"
}

if (-not (Get-Command fvm -ErrorAction SilentlyContinue)) {
  Write-Host "[setup] Installing FVM"
  dart pub global activate fvm
}

if ((Get-Command fvm -ErrorAction SilentlyContinue) -and (Test-Path (Join-Path $repoRoot 'fvm_config.json'))) {
  $version = $null
  try {
    $version = (Get-Content (Join-Path $repoRoot 'fvm_config.json') | ConvertFrom-Json).flutterSdkVersion
  } catch {
    $match = Select-String -Path (Join-Path $repoRoot 'fvm_config.json') -Pattern '\d+\.\d+\.\d+' | Select-Object -First 1
    if ($match) { $version = $match.Matches[0].Value }
  }
  $versionDir = Join-Path $env:FVM_HOME "versions/$version"
  if (Test-Path $versionDir) {
    if (Test-Path (Join-Path $versionDir '.git')) {
      Write-Host "[setup] FVM version $version already installed"
    } else {
      Write-Host "[setup] Removing corrupt FVM version $version"
      Remove-Item -Recurse -Force $versionDir
      Write-Host "[setup] Running fvm install"
      try { fvm install } catch { Write-Host "[setup] fvm install failed" }
    }
  } else {
    Write-Host "[setup] Running fvm install"
    try {
      fvm install
    } catch {
      Write-Host "[setup] fvm install failed; removing existing version $version"
      try { fvm remove $version } catch {}
      Remove-Item -Recurse -Force $versionDir -ErrorAction SilentlyContinue
      try { fvm install } catch { Write-Host "[setup] fvm install failed" }
    }
  }
}

if (-not (Get-Command markdownlint -ErrorAction SilentlyContinue)) {
  if (Get-Command npm -ErrorAction SilentlyContinue) {
    Write-Host "[setup] Installing markdownlint-cli"
    try { npm install -g markdownlint-cli } catch { Write-Host "[setup] Failed to install markdownlint-cli" }
  } else {
    Write-Host "[setup] npm not found; markdownlint will run via npx"
  }
}

# Ensure ImageMagick and FFmpeg are available for asset tooling.
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
  Write-Host "[setup] Installing FFmpeg"
  if (Get-Command winget -ErrorAction SilentlyContinue) {
    try { winget install -e --id FFmpeg.FFmpeg | Out-Null } catch { Write-Host "[setup] winget install FFmpeg failed" }
  } else {
    Write-Host "[setup] Skipping FFmpeg install: winget not found"
  }
}
if (-not (Get-Command magick -ErrorAction SilentlyContinue) -and -not (Get-Command convert -ErrorAction SilentlyContinue)) {
  Write-Host "[setup] Installing ImageMagick"
  if (Get-Command winget -ErrorAction SilentlyContinue) {
    try { winget install -e --id ImageMagick.ImageMagick | Out-Null } catch { Write-Host "[setup] winget install ImageMagick failed" }
  } else {
    Write-Host "[setup] Skipping ImageMagick install: winget not found"
  }
}

if (-not (Get-Command google-chrome -ErrorAction SilentlyContinue) -and `
    -not (Get-Command chrome -ErrorAction SilentlyContinue) -and `
    -not (Get-Command chromium -ErrorAction SilentlyContinue) -and `
    -not (Get-Command msedge -ErrorAction SilentlyContinue)) {
  Write-Host "[setup] Installing Chromium"
  if (Get-Command winget -ErrorAction SilentlyContinue) {
    try { winget install -e --id Chromium.Chromium | Out-Null } catch { Write-Host "[setup] winget install failed" }
  } else {
    Write-Host "[setup] Skipping Chrome install: winget not found"
  }
}

$chromePath = $null
if (Get-Command google-chrome -ErrorAction SilentlyContinue) { $chromePath = (Get-Command google-chrome).Source }
elseif (Get-Command chrome -ErrorAction SilentlyContinue) { $chromePath = (Get-Command chrome).Source }
elseif (Get-Command chromium -ErrorAction SilentlyContinue) { $chromePath = (Get-Command chromium).Source }
elseif (Get-Command msedge -ErrorAction SilentlyContinue) { $chromePath = (Get-Command msedge).Source }

if ($chromePath) {
  $env:CHROME_EXECUTABLE = $chromePath
  if (-not (Get-Content $shellProfile | Select-String 'CHROME_EXECUTABLE' -Quiet)) {
    Add-Content $shellProfile "`n" + '$env:CHROME_EXECUTABLE = "' + $chromePath + '"'
    Write-Host "[setup] Set CHROME_EXECUTABLE=$chromePath in $shellProfile"
  }
}

Write-Host "[setup] Completed"
} finally {
  Pop-Location
}

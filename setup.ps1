#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "[setup] Bootstrapping Flutter SDK"
& "$PSScriptRoot/scripts/bootstrap_flutter.ps1"

$repoRoot = Resolve-Path $PSScriptRoot
$pubCacheBin = Join-Path $HOME '.pub-cache/bin'
$flutterBin = Join-Path $repoRoot '.tooling/flutter/bin'

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
  dart pub global activate fvm | Out-Null
}

if ((Get-Command fvm -ErrorAction SilentlyContinue) -and (Test-Path (Join-Path $repoRoot 'fvm_config.json'))) {
  Write-Host "[setup] Running fvm install"
  try { fvm install | Out-Null } catch { Write-Host "[setup] fvm install failed" }
}

if (-not (Get-Command markdownlint -ErrorAction SilentlyContinue)) {
  Write-Host "[setup] Installing markdownlint-cli"
  try { npm install -g markdownlint-cli | Out-Null } catch { Write-Host "[setup] Failed to install markdownlint-cli" }
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

if (-not (Get-Command google-chrome -ErrorAction SilentlyContinue)) {
  if (Get-Command chromium -ErrorAction SilentlyContinue) {
    $env:CHROME_EXECUTABLE = 'chromium'
    if (-not (Get-Content $shellProfile | Select-String 'CHROME_EXECUTABLE' -Quiet)) {
      Add-Content $shellProfile "`n" + '$env:CHROME_EXECUTABLE = "chromium"'
      Write-Host "[setup] Set CHROME_EXECUTABLE=chromium in $shellProfile"
    }
  } elseif (Get-Command chrome -ErrorAction SilentlyContinue) {
    $env:CHROME_EXECUTABLE = 'chrome'
    if (-not (Get-Content $shellProfile | Select-String 'CHROME_EXECUTABLE' -Quiet)) {
      Add-Content $shellProfile "`n" + '$env:CHROME_EXECUTABLE = "chrome"'
      Write-Host "[setup] Set CHROME_EXECUTABLE=chrome in $shellProfile"
    }
  }
}

Write-Host "[setup] Completed"

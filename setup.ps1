#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Push-Location $PSScriptRoot
try {
Write-Host "[setup] Bootstrapping Flutter SDK"
# Forward -Verbose to bootstrap if this script is running verbose
$bootstrapArgs = @()
if ($VerbosePreference -eq 'Continue') { $bootstrapArgs += '-Verbose' }
& "$PSScriptRoot/scripts/bootstrap_flutter.ps1" @bootstrapArgs

$repoRoot = Resolve-Path $PSScriptRoot
$pubCacheBin = Join-Path $HOME '.pub-cache/bin'
$flutterBin = Join-Path $repoRoot '.tooling/flutter/bin'
$installTimeoutSec = 300
function Invoke-WingetInstall {
  param([string]$ArgsLine,[string]$Name)
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "[setup] Skipping $Name install: winget not found"
    return
  }
  Write-Host "[setup] Installing $Name"
  $job = Start-Job -ScriptBlock {
    param($Line)
    try { winget $Line | Out-Null } catch {}
  } -ArgumentList $ArgsLine
  if (-not (Wait-Job $job -Timeout $installTimeoutSec)) {
    try { Stop-Job $job -Force } catch {}
    Write-Host "[setup] winget install $Name timed out; continuing"
    return
  }
  try { Receive-Job $job -ErrorAction Stop | Out-Null } catch { Write-Host "[setup] winget install $Name failed" }
}

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
## FFmpeg install removed per request
## ImageMagick install removed per request

if (-not (Get-Command google-chrome -ErrorAction SilentlyContinue) -and `
    -not (Get-Command chrome -ErrorAction SilentlyContinue) -and `
    -not (Get-Command chromium -ErrorAction SilentlyContinue) -and `
    -not (Get-Command msedge -ErrorAction SilentlyContinue)) {
  Invoke-WingetInstall -ArgsLine 'install -e --id Chromium.Chromium --silent --accept-package-agreements --accept-source-agreements' -Name 'Chromium'
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

#!/usr/bin/env pwsh
[CmdletBinding()]
param(
  [switch]$Force,
  [switch]$Quiet,
  [ValidateSet('http')]
  [string]$Downloader = 'http'
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
$FLUTTER_DIR_FULL = [System.IO.Path]::GetFullPath($FLUTTER_DIR)

$flutterBinDir = Join-Path $FLUTTER_DIR 'bin'
try { $flutterBinDir = (Resolve-Path $flutterBinDir).Path } catch {}
$flutterBat    = Join-Path $flutterBinDir 'flutter.bat'

Say "Ensuring Flutter $FLUTTER_VERSION ($FLUTTER_CHANNEL) in $FLUTTER_DIR"

$needsDownload = $true
# If already present, ensure version/channel match; otherwise upgrade
if ((Test-Path $flutterBat) -and -not $Force) {
  Say "Existing Flutter installation detected; checking version"
  $versionOutput = $null
  try {
    $versionOutput = & $flutterBat --version 2>&1
    if ($LASTEXITCODE -ne 0) { throw "flutter --version exited with code $LASTEXITCODE" }
  } catch {
    Say "Flutter binary present but failed to run; treating as corrupt and reinstalling"
    try { if (Test-Path $FLUTTER_DIR_FULL) { Remove-Item $FLUTTER_DIR_FULL -Recurse -Force -ErrorAction SilentlyContinue } } catch {}
    $needsDownload = $true
    $versionOutput = $null
  }
  $currentVersion = $null
  $currentChannel = $null
  if ($versionOutput) { Say ("flutter --version output: " + ($versionOutput -replace "\r?\n"," ")) }
  # Be lenient about separators (console encoding may mangle the bullet character)
  $m = [regex]::Match($versionOutput, 'Flutter\s+([^\s]+)\s+.*?channel\s+([^\s]+)')
  if ($m.Success) {
    $currentVersion = $m.Groups[1].Value
    $currentChannel = $m.Groups[2].Value
    Say "Parsed installed Flutter: version=$currentVersion channel=$currentChannel"
  } else {
    Say "Unable to parse Flutter version; will reinstall"
  }
  if (($currentVersion -ne $null) -and ($currentChannel -ne $null) -and ($currentVersion -eq $FLUTTER_VERSION) -and ($currentChannel -eq $FLUTTER_CHANNEL)) {
    Say "Installed Flutter matches required version/channel"
    $needsDownload = $false
  } else {
    $cv = if ($null -ne $currentVersion) { $currentVersion } else { 'unknown' }
    $cc = if ($null -ne $currentChannel) { $currentChannel } else { 'unknown' }
    Say "Installed=$cv ($cc); required=$FLUTTER_VERSION ($FLUTTER_CHANNEL). Will (re)install."
    Say "Removing old Flutter installation"
    try { if (Test-Path $FLUTTER_DIR_FULL) { Remove-Item $FLUTTER_DIR_FULL -Recurse -Force -ErrorAction SilentlyContinue } } catch {}
    $needsDownload = $true
  }
} else {
  Say "No Flutter installation found"
}

if ($needsDownload) {
  Say "Bootstrapping Flutter $FLUTTER_VERSION ($FLUTTER_CHANNEL)"
  New-Item -ItemType Directory -Force -Path '.tooling' | Out-Null
  Push-Location '.tooling'
  try {
# --- Config & URL (keeps your env overrides) ---
$BASE_URL  = if ($env:FLUTTER_DOWNLOAD_MIRROR) { $env:FLUTTER_DOWNLOAD_MIRROR.TrimEnd('/') } else { 'https://storage.googleapis.com/flutter_infra_release/releases' }
$ARCHIVE   = "flutter_windows_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.zip"
$URL       = "$BASE_URL/$FLUTTER_CHANNEL/windows/$ARCHIVE"
$ExpectedSha256 = $env:FLUTTER_SHA256
$WorkDir = (Get-Location).Path

Say "Downloading: $URL (downloader=$Downloader)"

# --- Helpers ---
function Get-FileSha256 { param([string]$Path)
  if (!(Test-Path $Path)) { return $null }
  (Get-FileHash -Algorithm SHA256 -Path $Path).Hash.ToLowerInvariant()
}

function Write-ProgressLine([string]$activity,[long]$read,[Nullable[long]]$total,[double]$elapsedSec) {
  $mbRead=[math]::Round($read/1MB,1)
  $speed = if ($elapsedSec -gt 0) { [math]::Round(($read/1MB)/$elapsedSec,2) } else { 0 }
  if ($total) {
    $mbTot=[math]::Round($total/1MB,1)
    $pct=[int](($read*100.0)/$total)
    Write-Progress -Activity $activity -Status "$mbRead/$mbTot MB ($pct%) @ $speed MB/s" -PercentComplete $pct
  } else {
    Write-Progress -Activity $activity -Status "$mbRead MB @ $speed MB/s"
  }
}

# --- Download strategies ---
function Invoke-HttpDownload { param([string]$Url,[string]$Dest)
  Say "Using HttpClient (streaming)"
  Add-Type -AssemblyName System.Net.Http
  $client = [System.Net.Http.HttpClient]::new()
  $client.Timeout = [TimeSpan]::FromMinutes(30)

  $destFull = [System.IO.Path]::GetFullPath($Dest)
  $tmpFull  = $destFull + '.partial'
  $existing = if (Test-Path $tmpFull) { (Get-Item $tmpFull).Length } else { 0 }
  $req = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Get, $Url)
  if ($existing -gt 0) { $req.Headers.Range = [System.Net.Http.Headers.RangeHeaderValue]::new($existing, $null) }

  $resp = $null
  $in = $null
  $out = $null
  try {
    $resp = $client.SendAsync($req, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult()
    if (-not $resp.IsSuccessStatusCode -and $resp.StatusCode -ne 206) { throw "HTTP $($resp.StatusCode) downloading $Url" }
    $total = $resp.Content.Headers.ContentLength
    # PowerShell 5's HttpContent lacks a synchronous ReadAsStream method.
    # ReadAsStreamAsync() is available across .NET versions, so synchronously
    # wait for the stream to accommodate older runtimes.
    $in = $resp.Content.ReadAsStreamAsync().GetAwaiter().GetResult()
    $outMode = if ($existing -gt 0) {[System.IO.FileMode]::Append} else {[System.IO.FileMode]::Create}
    $out = [System.IO.File]::Open($tmpFull, $outMode, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)

    try {
      $sw=[System.Diagnostics.Stopwatch]::StartNew()
      $buf = New-Object byte[] (64KB)
      $read= $existing
      $last= 0
      while (($n = $in.Read($buf,0,$buf.Length)) -gt 0) {
        $out.Write($buf,0,$n); $read += $n
        if ($sw.ElapsedMilliseconds - $last -ge 100) {
          $last = $sw.ElapsedMilliseconds
          $grandTotal = if ($total) { $existing + $total } else { $null }
          Write-ProgressLine "Downloading Flutter" $read $grandTotal ($sw.Elapsed.TotalSeconds)
        }
      }
      Write-Progress -Activity "Downloading Flutter" -Completed
    } finally {
      if ($out) { $out.Dispose() }
      if ($in) { $in.Dispose() }
      if ($client) { $client.Dispose() }
    }

    if (Test-Path $tmpFull) {
      Move-Item -Force $tmpFull $destFull
    } else {
      throw "HttpClient download failed and fallbacks are temporarily disabled"
    }
  } catch {
    try { if (Test-Path $tmpFull) { Remove-Item -Force $tmpFull } } catch {}
    throw
  }
}

function Invoke-HttpRangeDownload { param([string]$Url,[string]$Dest,[int]$Parts=8) }

function Expand-ZipWithProgress { param([string]$ZipPath,[string]$Destination='.')
  Say "Extracting archive with progress"
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $zip = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
  try {
    $count = $zip.Entries.Count
    $i = 0
    foreach ($entry in $zip.Entries) {
      $i++
      $targetPath = Join-Path $Destination $entry.FullName
      $dir = Split-Path $targetPath -Parent
      if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
      if (-not $entry.FullName.EndsWith('/')) {
        $entryStream = $entry.Open()
        try {
          $out = [System.IO.File]::Open($targetPath,[System.IO.FileMode]::Create,[System.IO.FileAccess]::Write,[System.IO.FileShare]::None)
          try {
            $buf = New-Object byte[] (64KB)
            while (($n=$entryStream.Read($buf,0,$buf.Length)) -gt 0) { $out.Write($buf,0,$n) }
          } finally { $out.Dispose() }
        } finally { $entryStream.Dispose() }
      }
      $pct=[int](($i*100.0)/$count)
      Write-Progress -Activity "Extracting Flutter SDK" -Status "$i of $count" -PercentComplete $pct
    }
    Write-Progress -Activity "Extracting Flutter SDK" -Completed
  } finally { $zip.Dispose() }
}

# --- Orchestrate ---
$destZip = Join-Path $WorkDir $ARCHIVE
$ProgressPreferenceBak = $global:ProgressPreference; $global:ProgressPreference = 'Continue'
try {
  # HttpClient-only, with reuse of existing archive if present
  $shouldDownload = $true
  if (Test-Path $destZip) {
    if ($ExpectedSha256) {
      Say "Existing archive found; verifying SHA256"
      $actualExisting = Get-FileSha256 $destZip
      if ($actualExisting -and ($actualExisting -eq $ExpectedSha256.ToLowerInvariant())) {
        Say "Existing archive checksum OK; reusing download"
        $shouldDownload = $false
      } else {
        Say "Existing archive checksum mismatch; re-downloading"
        try { Remove-Item -Force $destZip } catch {}
      }
    } else {
      Say "Existing archive found; reusing download"
      $shouldDownload = $false
    }
  }
  if ($shouldDownload) {
    # Clean any stale artifacts before starting a fresh download/extract
    try { if (Test-Path $destZip) { Remove-Item -Force $destZip -ErrorAction SilentlyContinue } } catch {}
    try { if (Test-Path "$destZip.partial") { Remove-Item -Force "$destZip.partial" -ErrorAction SilentlyContinue } } catch {}
    try { if (Test-Path $FLUTTER_DIR_FULL) { Remove-Item -Recurse -Force $FLUTTER_DIR_FULL -ErrorAction SilentlyContinue } } catch {}
    $preExtractTmp = Join-Path $WorkDir "_extract_flutter_tmp"
    try { if (Test-Path $preExtractTmp) { Remove-Item -Recurse -Force $preExtractTmp -ErrorAction SilentlyContinue } } catch {}
    Invoke-HttpDownload -Url $URL -Dest $destZip
  }

  if ($ExpectedSha256) {
    Say "Verifying SHA256"
    $actual = Get-FileSha256 $destZip
    if ($actual -ne $ExpectedSha256.ToLowerInvariant()) {
      throw "Checksum mismatch for $ARCHIVE. Expected $ExpectedSha256, got $actual"
    }
  }

  # Extract to a temp directory first for atomic install
  $extractRoot = Join-Path $WorkDir "_extract_flutter_tmp"
  try { if (Test-Path $extractRoot) { Remove-Item -Recurse -Force $extractRoot } } catch {}
  New-Item -ItemType Directory -Force -Path $extractRoot | Out-Null
  try {
    Expand-ZipWithProgress -ZipPath $destZip -Destination $extractRoot
    # The zip contains a top-level 'flutter' directory
    $tempFlutter = Join-Path $extractRoot 'flutter'
    if (-not (Test-Path $tempFlutter)) { throw "Extracted archive missing 'flutter' directory" }
    # Replace existing installation
    try { if (Test-Path $FLUTTER_DIR_FULL) { Remove-Item -Recurse -Force $FLUTTER_DIR_FULL } } catch {}
    Move-Item -Force $tempFlutter $FLUTTER_DIR_FULL
  } catch {
    # Cleanup temp on failure to avoid future corruption
    try { if (Test-Path $extractRoot) { Remove-Item -Recurse -Force $extractRoot } } catch {}
    throw
  }
  # Cleanup temp after successful move
  try { if (Test-Path $extractRoot) { Remove-Item -Recurse -Force $extractRoot } } catch {}
} finally {
  $global:ProgressPreference = $ProgressPreferenceBak
}
Remove-Item $destZip -Force
} finally {
  Pop-Location
}

}

if ($needsDownload) {
  Say "Flutter SDK installed at $FLUTTER_DIR"
} else {
  Say "Flutter SDK already present at $FLUTTER_DIR"
}

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

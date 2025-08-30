#!/usr/bin/env pwsh
[CmdletBinding()]
param(
  [switch]$Force,
  [switch]$Quiet,
  [ValidateSet('http','ranges')]
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

$flutterBinDir = Join-Path $FLUTTER_DIR 'bin'
try { $flutterBinDir = (Resolve-Path $flutterBinDir).Path } catch {}
$flutterBat    = Join-Path $flutterBinDir 'flutter.bat'

Say "Ensuring Flutter $FLUTTER_VERSION ($FLUTTER_CHANNEL) in $FLUTTER_DIR"

# If already present, ensure version/channel match; otherwise upgrade
if ((Test-Path $flutterBat) -and -not $Force) {
  Say "Existing Flutter installation detected; checking version"
  $versionOutput = & $flutterBat --version
  $currentVersion = $null
  $currentChannel = $null
  if ($versionOutput -match 'Flutter\s+([^\s]+)\s+•\s+channel\s+([^\s]+)') {
    $currentVersion = $matches[1]
    $currentChannel = $matches[2]
  } else {
    Say "Unable to parse Flutter version from output: $versionOutput"
  }
  if (($currentVersion -eq $FLUTTER_VERSION) -and ($currentChannel -eq $FLUTTER_CHANNEL)) {
    Say "Flutter $currentVersion ($currentChannel) already installed"
    $env:PATH = "$flutterBinDir;$env:PATH"
    try { git config --global --add safe.directory (Resolve-Path "$FLUTTER_DIR").Path } catch {}
    Say $versionOutput
    return
  } else {
    $cv = if ($null -ne $currentVersion) { $currentVersion } else { 'unknown' }
    $cc = if ($null -ne $currentChannel) { $currentChannel } else { 'unknown' }
    Say "Flutter $cv ($cc) found, but $FLUTTER_VERSION ($FLUTTER_CHANNEL) required"
    Say "Removing old Flutter installation"
    Remove-Item $FLUTTER_DIR -Recurse -Force
  }
} else {
  Say "No Flutter installation found"
}

Say "Bootstrapping Flutter $FLUTTER_VERSION ($FLUTTER_CHANNEL)"
New-Item -ItemType Directory -Force -Path '.tooling' | Out-Null
Push-Location '.tooling'
# --- Config & URL (keeps your env overrides) ---
$BASE_URL  = if ($env:FLUTTER_DOWNLOAD_MIRROR) { $env:FLUTTER_DOWNLOAD_MIRROR.TrimEnd('/') } else { 'https://storage.googleapis.com/flutter_infra_release/releases' }
$ARCHIVE   = "flutter_windows_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.zip"
$URL       = "$BASE_URL/$FLUTTER_CHANNEL/windows/$ARCHIVE"
$ExpectedSha256 = $env:FLUTTER_SHA256

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
function Download-With-Http { param([string]$Url,[string]$Dest)
  Say "Using HttpClient (streaming)"
  Add-Type -AssemblyName System.Net.Http
  $client = [System.Net.Http.HttpClient]::new()
  $client.Timeout = [TimeSpan]::FromMinutes(30)

  $tmp = "$Dest.partial"
  $existing = if (Test-Path $tmp) { (Get-Item $tmp).Length } else { 0 }
  $req = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Get, $Url)
  if ($existing -gt 0) { $req.Headers.Range = [System.Net.Http.Headers.RangeHeaderValue]::new($existing, $null) }

  $resp = $client.SendAsync($req, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult()
  if (-not $resp.IsSuccessStatusCode -and $resp.StatusCode -ne 206) { throw "HTTP $($resp.StatusCode) downloading $Url" }
  $total = $resp.Content.Headers.ContentLength
  # PowerShell 5's HttpContent lacks a synchronous ReadAsStream method.
  # ReadAsStreamAsync() is available across .NET versions, so synchronously
  # wait for the stream to accommodate older runtimes.
  $in    = $resp.Content.ReadAsStreamAsync().GetAwaiter().GetResult()
  $outMode = if ($existing -gt 0) {[System.IO.FileMode]::Append} else {[System.IO.FileMode]::Create}
  $out  = [System.IO.File]::Open($tmp, $outMode, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)

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
  } finally { $out.Dispose(); $in.Dispose(); $client.Dispose() }

  Move-Item -Force $tmp $Dest
}

function Download-With-Ranges { param([string]$Url,[string]$Dest,[int]$Parts=8)
  Say "Using parallel HTTP ranges ($Parts parts)"
  Add-Type -AssemblyName System.Net.Http
  $client = [System.Net.Http.HttpClient]::new()
  $client.Timeout = [TimeSpan]::FromMinutes(30)

  # HEAD to get length
  $req0 = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Head, $Url)
  $resp0 = $client.SendAsync($req0).GetAwaiter().GetResult()
  if (-not $resp0.IsSuccessStatusCode) { throw "HEAD HTTP $($resp0.StatusCode)" }
  $len = $resp0.Content.Headers.ContentLength
  if (-not $len) { Say "Server did not return length; falling back to single stream"; $client.Dispose(); return Download-With-Http -Url $Url -Dest $Dest }

  # plan ranges
  $chunk = [Math]::Ceiling($len / $Parts)
  $tmpFiles = @()
  $jobs = 0..($Parts-1) | ForEach-Object {
    $start = $_ * $chunk
    $end   = [Math]::Min($start + $chunk - 1, $len - 1)
    if ($start -gt $end) { return $null }
    $tmp = [System.IO.Path]::GetTempFileName()
    $tmpFiles += $tmp
    Start-Job -ScriptBlock {
      param($Url,$Start,$End,$Tmp)
      Add-Type -AssemblyName System.Net.Http
      $client = [System.Net.Http.HttpClient]::new()
      $client.Timeout = [TimeSpan]::FromMinutes(30)
      $req = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Get, $Url)
      $req.Headers.Range = [System.Net.Http.Headers.RangeHeaderValue]::new($Start, $End)
      $resp = $client.SendAsync($req, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult()
      if (-not $resp.IsSuccessStatusCode -and $resp.StatusCode -ne 206) { throw "HTTP $($resp.StatusCode)" }
      # Use ReadAsStreamAsync() for compatibility with older .NET/PowerShell versions
      $in = $resp.Content.ReadAsStreamAsync().GetAwaiter().GetResult()
      $out=[System.IO.File]::Open($Tmp,[System.IO.FileMode]::Create,[System.IO.FileAccess]::Write,[System.IO.FileShare]::None)
      try {
        $buf = New-Object byte[] (64KB)
        while (($n=$in.Read($buf,0,$buf.Length)) -gt 0) { $out.Write($buf,0,$n) }
      } finally { $out.Dispose(); $in.Dispose(); $client.Dispose() }
    } -ArgumentList $Url,$start,$end,$tmp
  } | Where-Object { $_ -ne $null }

  # simple progress (poll sizes)
  $sw=[System.Diagnostics.Stopwatch]::StartNew()
  do {
    $sizes = 0
    foreach ($f in $tmpFiles) { if (Test-Path $f) { $sizes += (Get-Item $f).Length } }
    Write-ProgressLine "Downloading Flutter (parallel ranges)" $sizes $len ($sw.Elapsed.TotalSeconds)
    Start-Sleep -Milliseconds 200
    $states = $jobs | ForEach-Object { $_.State }
  } while ($states -contains 'Running')

  Receive-Job -Job $jobs -ErrorAction Stop | Out-Null
  Write-Progress -Activity "Downloading Flutter (parallel ranges)" -Completed

  # concatenate
  $out=[System.IO.File]::Open($Dest,[System.IO.FileMode]::Create,[System.IO.FileAccess]::Write,[System.IO.FileShare]::None)
  try {
    for ($i=0; $i -lt $tmpFiles.Count; $i++) {
      $in=[System.IO.File]::OpenRead($tmpFiles[$i])
      try {
        $buf = New-Object byte[] (1MB)
        while (($n=$in.Read($buf,0,$buf.Length)) -gt 0) { $out.Write($buf,0,$n) }
      } finally { $in.Dispose() }
      Remove-Item $tmpFiles[$i] -Force
    }
  } finally { $out.Dispose() }
  $client.Dispose()
}

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
$destZip = $ARCHIVE
$ProgressPreferenceBak = $global:ProgressPreference; $global:ProgressPreference = 'Continue'
try {
  switch ($Downloader) {
    'ranges' { Download-With-Ranges -Url $URL -Dest $destZip }
    default  { Download-With-Http   -Url $URL -Dest $destZip }
  }

  if ($ExpectedSha256) {
    Say "Verifying SHA256"
    $actual = Get-FileSha256 $destZip
    if ($actual -ne $ExpectedSha256.ToLowerInvariant()) {
      throw "Checksum mismatch for $ARCHIVE. Expected $ExpectedSha256, got $actual"
    }
  }

  Expand-ZipWithProgress -ZipPath $destZip -Destination '.'
} finally {
  $global:ProgressPreference = $ProgressPreferenceBak
}
Remove-Item $destZip -Force

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

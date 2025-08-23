#!/usr/bin/env pwsh
# Usage: scripts\dartw.ps1 pub get
$ErrorActionPreference = 'Stop'
& "$PSScriptRoot\bootstrap_flutter.ps1"
& "$PWD\.tooling\flutter\bin\dart.exe" @Args

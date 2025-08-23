#!/usr/bin/env pwsh
# Usage: scripts\flutterw.ps1 run -d chrome
$ErrorActionPreference = 'Stop'
& "$PSScriptRoot\bootstrap_flutter.ps1"
& "$PWD\.tooling\flutter\bin\flutter.bat" @Args

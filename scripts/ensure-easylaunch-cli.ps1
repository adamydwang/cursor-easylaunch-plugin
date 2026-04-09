Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$BASE = "https://little-two-packages.oss-cn-hongkong.aliyuncs.com/cli"
$platform = "windows-amd64"
$url = "$BASE/$platform/easylaunch-cli"

$destDir = Join-Path $env:USERPROFILE ".easylaunch\bin"
$dest = Join-Path $destDir "easylaunch-cli.exe"

New-Item -ItemType Directory -Force -Path $destDir | Out-Null

Invoke-WebRequest $url -OutFile $dest

Write-Host "EasyLaunch CLI installed at:"
Write-Host $dest
Write-Host ""
Write-Host "PowerShell (current session):"
Write-Host ("  $env:EASYLAUNCH_CLI = `"{0}`"" -f $dest)

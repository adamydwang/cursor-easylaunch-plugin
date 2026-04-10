Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# PowerShell 5.1 on older Windows can default to TLS 1.0/1.1.
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

$BASE = "https://little-two-packages.oss-cn-hongkong.aliyuncs.com/cli"
$platform = "windows-amd64"
$url = "$BASE/$platform/easylaunch-cli"

$destDir = Join-Path $env:USERPROFILE ".easylaunch\bin"
$dest = Join-Path $destDir "easylaunch-cli.exe"

New-Item -ItemType Directory -Force -Path $destDir | Out-Null

try {
  if (Get-Command Invoke-WebRequest -ErrorAction SilentlyContinue) {
    # -UseBasicParsing exists on Windows PowerShell 5.1; it is removed in PowerShell 6+.
    $supportsBasicParsing = $false
    try { $supportsBasicParsing = (Get-Command Invoke-WebRequest).Parameters.ContainsKey("UseBasicParsing") } catch {}
    if ($supportsBasicParsing) {
      Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
    } else {
      Invoke-WebRequest -Uri $url -OutFile $dest
    }
  } else {
    throw "Invoke-WebRequest is not available in this PowerShell."
  }
} catch {
  Write-Error "Failed to download EasyLaunch CLI from: $url"
  throw
}

Write-Host "EasyLaunch CLI installed at:"
Write-Host $dest
Write-Host ""
Write-Host "PowerShell (current session):"
Write-Host ("  $env:EASYLAUNCH_CLI = `"{0}`"" -f $dest)

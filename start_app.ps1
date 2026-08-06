$ErrorActionPreference = "Stop"

function Test-CommandExists {
  param([string]$CommandName)

  return $null -ne (Get-Command $CommandName -ErrorAction SilentlyContinue)
}

if (-not (Test-CommandExists "uv")) {
  Write-Error "Missing required command: uv"
}

if (-not (Test-CommandExists "pnpm")) {
  Write-Error "Missing required command: pnpm"
}

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Start each service in its own PowerShell window with script execution bypassed.
if (Test-Path "$repoRoot\livekit-server.exe") {
  Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass", "-NoExit", "-Command", "Set-Location '$repoRoot'; .\livekit-server.exe --dev"
} elseif (Test-CommandExists "livekit-server") {
  Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass", "-NoExit", "-Command", "Set-Location '$repoRoot'; livekit-server --dev"
} else {
  Write-Warning "livekit-server was not found. Skipping local LiveKit startup and using your configured LIVEKIT_URL instead."
}

Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass", "-NoExit", "-Command", "Set-Location '$repoRoot\backend'; uv run python src/agent.py dev"
# Use pnpm.cmd to prevent execution policy errors on pnpm.ps1 wrapper
Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass", "-NoExit", "-Command", "Set-Location '$repoRoot\frontend'; pnpm.cmd dev"

Write-Host "Started backend and frontend in separate PowerShell windows."

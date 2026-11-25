# Run ONCE after copying a new version of the project over the old one:  .\UPDATE.ps1
# (Your data in MongoDB is kept. This only installs packages and adds any new tables.)
$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

Write-Host "`n[1/4] Backend packages + database tables..." -ForegroundColor Cyan
Set-Location "$root\backend"
npm install
npm run prisma:generate
npm run prisma:push

Write-Host "`n[2/4] Frontend packages..." -ForegroundColor Cyan
Set-Location "$root\frontend"
npm install

Write-Host "`n[3/4] Camera proctoring service packages..." -ForegroundColor Cyan
$svc = "$root\proctoring-service"
if (Get-Command python -ErrorAction SilentlyContinue) {
  Set-Location $svc
  if (-not (Test-Path "$svc\venv\Scripts\python.exe")) { python -m venv venv }
  & "$svc\venv\Scripts\python.exe" -m pip install -r requirements.txt
} else {
  Write-Host "Python not found - skipping (face checks stay off)." -ForegroundColor Yellow
}

Write-Host "`n[4/4] Done. Close the server windows (if open), then run  .\START.ps1" -ForegroundColor Green
Set-Location $root

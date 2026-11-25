# ONE-TIME SETUP. Right-click this folder in VS Code -> open terminal -> run:  .\SETUP.ps1
$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

Write-Host "`n=== Code Mentor AI setup ===" -ForegroundColor Cyan
Write-Host "Using the .env files already included (backend\.env and frontend\.env)." -ForegroundColor Green

Write-Host "`n[1/6] Installing backend packages (takes a few minutes)..." -ForegroundColor Cyan
Set-Location "$root\backend"
npm install
foreach ($p in "@prisma/client@5.19.1","@prisma/engines@5.19.1","prisma@5.19.1","argon2@0.40.3","esbuild@0.21.5") {
  npm approve-scripts $p 2>$null | Out-Null
}
npm install

Write-Host "`n[2/6] Creating database tables..." -ForegroundColor Cyan
npm run prisma:generate
npm run prisma:push

Write-Host "`n[3/6] Loading courses and coding problems..." -ForegroundColor Cyan
npm run seed:courses
npm run seed:coding

Write-Host "`n[4/6] Installing frontend packages..." -ForegroundColor Cyan
Set-Location "$root\frontend"
npm install

Write-Host "`n[5/6] Camera proctoring service (Python)..." -ForegroundColor Cyan
$svc = "$root\proctoring-service"
Set-Location $svc
$py = Get-Command python -ErrorAction SilentlyContinue
if (-not $py) {
  Write-Host "Python was not found, so the camera checks are skipped. Install Python 3.10-3.13 from python.org (tick 'Add to PATH'), then run .\SETUP.ps1 again. Exams still work without it." -ForegroundColor Yellow
} else {
  python -m venv venv
  & "$svc\venv\Scripts\python.exe" -m pip install --upgrade pip
  & "$svc\venv\Scripts\python.exe" -m pip install -r requirements.txt
  if ($LASTEXITCODE -ne 0) { Write-Host "Installing the Python packages failed - see the messages above." -ForegroundColor Yellow }
  if (-not (Test-Path "$svc\models\shape_predictor_68_face_landmarks.dat") -or -not (Test-Path "$svc\models\yolov3-tiny.weights")) {
    Write-Host "Two large model files are still needed. Run:  .\proctoring-service\copy-models.ps1" -ForegroundColor Yellow
  }
}

Write-Host "`n[6/6] Done!" -ForegroundColor Green
Write-Host "Now run:  .\START.ps1   (from the project folder)" -ForegroundColor Yellow
Set-Location $root

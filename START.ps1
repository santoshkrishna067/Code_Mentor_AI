# Run every time you want to use the site:  .\START.ps1
$root = $PSScriptRoot
Start-Process powershell -ArgumentList "-NoExit","-Command","cd '$root\backend'; npm run dev"
Start-Process powershell -ArgumentList "-NoExit","-Command","cd '$root\frontend'; npm run dev"
$svc = "$root\proctoring-service"
if ((Test-Path "$svc\venv\Scripts\python.exe") -and (Test-Path "$svc\models\shape_predictor_68_face_landmarks.dat") -and (Test-Path "$svc\models\yolov3-tiny.weights")) {
  Start-Process powershell -ArgumentList "-NoExit","-Command","cd '$svc'; .\venv\Scripts\python.exe server.py"
  Write-Host "Camera proctoring service started (third window)." -ForegroundColor Green
} else {
  Write-Host "Camera proctoring service NOT started (not set up yet). Exams still run; face checks are skipped. See proctoring-service\README.md." -ForegroundColor Yellow
}
Start-Sleep -Seconds 8
Start-Process "http://localhost:5173"
Write-Host "Windows opened for the backend, the frontend and (if set up) the camera service. Keep them open while using the site." -ForegroundColor Green

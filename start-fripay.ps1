# FriPay Microservices Startup Script
$PHP = "C:\laragon\bin\php\php-8.3.16-Win32-vs16-x64\php.exe"
$ROOT = "C:\laragon\www"

Write-Host "=== FriPay - Demarrage des microservices ===" -ForegroundColor Green

# Start Users Service (port 8000)
Write-Host "[1/4] Users Service (port 8000)..." -NoNewline
$p1 = Start-Process -NoNewWindow -FilePath $PHP -ArgumentList "-S 0.0.0.0:8000 -t $ROOT\fripay-users\public" -PassThru
Start-Sleep 2
Write-Host " OK (PID: $($p1.Id))" -ForegroundColor Green

# Start Payments Service (port 8001)
Write-Host "[2/4] Payments Service (port 8001)..." -NoNewline
$p2 = Start-Process -NoNewWindow -FilePath $PHP -ArgumentList "-S 0.0.0.0:8001 -t $ROOT\fripay-payments\public" -PassThru
Start-Sleep 2
Write-Host " OK (PID: $($p2.Id))" -ForegroundColor Green

# Start Admin Service (port 8002)
Write-Host "[3/4] Admin Service (port 8002)..." -NoNewline
$p3 = Start-Process -NoNewWindow -FilePath $PHP -ArgumentList "-S 0.0.0.0:8002 -t $ROOT\fripay-admin\public" -PassThru
Start-Sleep 2
Write-Host " OK (PID: $($p3.Id))" -ForegroundColor Green

# Start API Gateway (port 8080)
Write-Host "[4/4] API Gateway (port 8080)..." -NoNewline
$p4 = Start-Process -NoNewWindow -FilePath $PHP -ArgumentList "-S 0.0.0.0:8080 -t $ROOT\fripay-gateway\public" -PassThru
Start-Sleep 2
Write-Host " OK (PID: $($p4.Id))" -ForegroundColor Green

Write-Host "`n=== Tous les services sont demarres ! ===" -ForegroundColor Green
Write-Host "Users:    http://localhost:8000/api/v1/up"
Write-Host "Payments: http://localhost:8001/api/v1/up"
Write-Host "Admin:    http://localhost:8002/api/v1/up"
Write-Host "Gateway:  http://localhost:8080/api/v1/auth/register"

@echo off
title FriPay Microservices
color 0A
echo ============================================================
echo   FriPay - Demarrage des microservices
echo ============================================================
echo.

set PHP=C:\laragon\bin\php\php-8.3.16-Win32-vs16-x64\php.exe
set ROOT=C:\laragon\www

echo [1/4] Demarrage Users Service (port 8000)...
start "FriPay-Users" cmd /c "%PHP% %ROOT%\fripay-users\artisan serve --port=8000"
timeout /t 3 /nobreak >nul

echo [2/4] Demarrage Payments Service (port 8001)...
start "FriPay-Payments" cmd /c "%PHP% %ROOT%\fripay-payments\artisan serve --port=8001"
timeout /t 3 /nobreak >nul

echo [3/4] Demarrage Admin Service (port 8002)...
start "FriPay-Admin" cmd /c "%PHP% %ROOT%\fripay-admin\artisan serve --port=8002"
timeout /t 3 /nobreak >nul

echo [4/4] Demarrage API Gateway (port 8080)...
start "FriPay-Gateway" cmd /c "%PHP% -S localhost:8080 -t %ROOT%\fripay-gateway\public"
timeout /t 2 /nobreak >nul

echo.
echo ============================================================
echo   Tous les services sont en cours de demarrage !
echo.
echo   Users Service   : http://localhost:8000/api/v1/up
echo   Payments Service: http://localhost:8001/api/v1/up
echo   Admin Service   : http://localhost:8002/api/v1/up
echo   API Gateway     : http://localhost:8080/api/v1/auth/register
echo ============================================================
echo.
pause

@echo off
echo ============================================================
echo   FriPay API Gateway - Redirection vers les microservices
echo ============================================================
echo.
echo Services attendus :
echo   Users Service   : http://localhost:8000
echo   Payments Service: http://localhost:8001
echo   Admin Service   : http://localhost:8002
echo.
echo Gateway demarree sur : http://localhost:8080
echo.
echo Lancement...
C:\laragon\bin\php\php-8.3.16-Win32-vs16-x64\php.exe -S localhost:8080 -t public

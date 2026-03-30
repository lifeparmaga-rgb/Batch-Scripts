@echo off
:menu
cls
echo ====================================
echo       برنامج تشغيل التطبيقات      
echo ====================================
echo.
echo 1 - (Notepad)
echo 2 - (Calculator)
echo 3 - (Edge)
echo 4 - Exit
echo.
set /p choice=Choose App :

if "%choice%"=="1" (
    start notepad
    goto menu
)

if "%choice%"=="2" (
    start calc
    goto menu
)

if "%choice%"=="3" (
    start msedge
    goto menu
)

if "%choice%"=="4" (
    exit
)

echo خيار غير صحيح. حاول مرة أخرى.
pause
goto menu

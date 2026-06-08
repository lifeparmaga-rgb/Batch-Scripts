@echo off
title Countdown Timer
setlocal EnableDelayedExpansion

:: ====== مسار ملف الصوت ======
set SOUND_FILE="D:\050.mp3"
:: ============================

:: التأكد من وجود ملف الصوت
if not exist "%SOUND_FILE%" (
    echo File Sound Not Found!!!
    pause
    exit /b
)

:: طلب الوقت بالدقايق
set /p MINUTES=Enter Time By Minutes: 

:: التأكد إن الإدخال رقم
for /f "delims=0123456789" %%a in ("%MINUTES%") do (
    echo Invalid Input
    pause
    exit /b
)

set /a TOTAL_SECONDS=MINUTES*60

:loop
cls

:: حساب الدقايق والثواني
set /a MINS=TOTAL_SECONDS/60
set /a SECS=TOTAL_SECONDS%%60

:: عرض MM:SS
if %SECS% LSS 10 (
    echo Remain Time: %MINS%:0%SECS%
) else (
    echo Remain Time: %MINS%:%SECS%
)

if %TOTAL_SECONDS% LEQ 0 goto done

set /a TOTAL_SECONDS-=1
timeout /t 1 /nobreak >nul
goto loop

:done
echo.
echo ⏰ Time Ended!
start "" "%SOUND_FILE%"
pause
exit

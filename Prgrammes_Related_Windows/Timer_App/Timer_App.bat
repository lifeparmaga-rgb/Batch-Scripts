@echo off
title Advanced Countdown Timer
setlocal EnableDelayedExpansion

:: ==============================
:: إعدادات
:: ==============================
set SOUND_FILE=D:\050.mp3
set LOG_FILE=%~dp0Timer_Log.txt
:: ==============================

:: التحقق من ملف الصوت
if not exist "%SOUND_FILE%" (
    echo Sound file not found!
    pause
    exit /b
)

:START_OVER
cls
echo ===============================
echo        COUNTDOWN TIMER
echo ===============================
echo.

:: ==============================
:: إدخال الوقت الأساسي
:: ==============================
set /p MINUTES=Enter Main Time (minutes): 

for /f "delims=0123456789" %%a in ("%MINUTES%") do (
    echo Invalid Input!
    pause
    goto START_OVER
)

set /a MAIN_SECONDS=MINUTES*60
set TOTAL_SECONDS=%MAIN_SECONDS%

:: ==============================
:: المؤقت الأساسي
:: ==============================
:MAIN_LOOP
cls
set /a MINS=TOTAL_SECONDS/60
set /a SECS=TOTAL_SECONDS%%60

if %SECS% LSS 10 (
    echo Remaining Time: %MINS%:0%SECS%
) else (
    echo Remaining Time: %MINS%:%SECS%
)

if %TOTAL_SECONDS% LEQ 0 goto MAIN_DONE

set /a TOTAL_SECONDS-=1
timeout /t 1 /nobreak >nul
goto MAIN_LOOP

:MAIN_DONE
echo.
echo ⏰ Main Time Ended!
start "" "%SOUND_FILE%"

:: ==============================
:: إدخال الوقت الإضافي
:: ==============================
echo.
set /p EXTRA_MINUTES=Enter Extra Productive Time (minutes): 

for /f "delims=0123456789" %%a in ("%EXTRA_MINUTES%") do (
    echo Invalid Input!
    pause
    goto START_OVER
)

taskkill /im wmplayer.exe /f >nul 2>&1
taskkill /im vlc.exe /f >nul 2>&1

set /a EXTRA_SECONDS=EXTRA_MINUTES*60
set TOTAL_SECONDS=%EXTRA_SECONDS%

:: ==============================
:: المؤقت الإضافي
:: ==============================
:EXTRA_LOOP
cls
set /a MINS=TOTAL_SECONDS/60
set /a SECS=TOTAL_SECONDS%%60

if %SECS% LSS 10 (
    echo Extra Time: %MINS%:0%SECS%
) else (
    echo Extra Time: %MINS%:%SECS%
)

if %TOTAL_SECONDS% LEQ 0 goto EXTRA_DONE

set /a TOTAL_SECONDS-=1
timeout /t 1 /nobreak >nul
goto EXTRA_LOOP

:EXTRA_DONE
echo.
echo ✅ Extra Productive Time Finished!
start "" "%SOUND_FILE%"

:: ==============================
:: التسجيل في الملف
:: ==============================
set /a TOTAL_MINUTES=MINUTES+EXTRA_MINUTES

echo ------------------------------------ >> "%LOG_FILE%"
echo Date: %date%  Time: %time% >> "%LOG_FILE%"
echo Main Time   : %MINUTES% minutes >> "%LOG_FILE%"
echo Extra Time  : %EXTRA_MINUTES% minutes >> "%LOG_FILE%"
echo Total Time  : %TOTAL_MINUTES% minutes >> "%LOG_FILE%"

echo.
echo 📝 Session Saved to:
echo %LOG_FILE%
pause
goto START_OVER

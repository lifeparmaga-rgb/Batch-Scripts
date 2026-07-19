@echo off
title Triple Productivity Timer
setlocal EnableExtensions EnableDelayedExpansion

:: ==========================================
:: إعدادات الأصوات
:: ==========================================
:: D:\Sounds\love_salah.mp4
:: D:\Sounds\050.mp3

set "SOUND1=D:\Sounds\love_salah.mp3"
set "SOUND2=D:\Sounds\050.mp3"
set "SOUND3=D:\Sounds\Production_Start_Repeated.mp3"
:: ==========================================

:START
cls
echo ======================================
echo        PRODUCTIVITY TIMER
echo ======================================
echo.

:: ==============================
:: المؤقت الاول
:: ==============================
set /p TIME1=Enter First Time (minutes):

:: ==============================
:: المؤقت الثاني
:: ==============================
set /p TIME2=Enter Second Time (minutes):

:: ==============================
:: المؤقت الثالث
:: ==============================
set /p TIME3=Enter Third Time (minutes):

:: تحويل لثواني
set /a TIMER1=%TIME1%*60
set /a TIMER2=%TIME2%*60
set /a TIMER3=%TIME3%*60


:: ==============================
:: المؤقت الاول
:: ==============================
set TOTAL_SECONDS=%TIMER1%
set TIMER_NAME=FIRST
call :RUN_TIMER

echo FIRST Timer Finished!

if exist "%SOUND1%" (
start "" "%SOUND1%"
timeout /t 7 /nobreak >nul
taskkill /f /im Microsoft.Media.Player.exe >nul 2>&1
)


:: ==============================
:: المؤقت الثاني
:: ==============================
set TOTAL_SECONDS=%TIMER2%
set TIMER_NAME=SECOND
call :RUN_TIMER

echo SECOND Timer Finished!

if exist "%SOUND2%" (
start "" "%SOUND2%"
timeout /t 12 /nobreak >nul
taskkill /f /im Microsoft.Media.Player.exe >nul 2>&1
)


:: ==============================
:: المؤقت الثالث
:: ==============================
set TOTAL_SECONDS=%TIMER3%
set TIMER_NAME=THIRD
call :RUN_TIMER

echo THIRD Timer Finished!

if exist "%SOUND3%" (
start "" "%SOUND3%"
)

echo.
echo All Timers Finished!
pause
goto START


:: ==========================================
:: دالة المؤقت
:: ==========================================
:RUN_TIMER

:TIMER_LOOP
cls

set /a MINS=TOTAL_SECONDS/60
set /a SECS=TOTAL_SECONDS%%60

echo ================================
echo        !TIMER_NAME! TIMER
echo ================================
echo.

if !SECS! LSS 10 (
echo Time: !MINS!:0!SECS!
) else (
echo Time: !MINS!:!SECS!
)

if !TOTAL_SECONDS! LEQ 0 goto TIMER_DONE

set /a TOTAL_SECONDS-=1
timeout /t 1 >nul
goto TIMER_LOOP

:TIMER_DONE
exit /b
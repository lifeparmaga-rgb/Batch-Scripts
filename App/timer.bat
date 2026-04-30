::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
title __Timer__
::Explanation:
::set /p: Prompts the user for input.
::set /a: Performs arithmetic to convert minutes into seconds.
::timeout /t: Waits for the specified number of seconds. The /nobreak flag prevents the user ::from interrupting the timer with a key press.
::pause: Waits for the user to press a key before closing the script.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off

:: Get the number of minutes from the user
::::::::::::::::::::::::::::::::::::::::::::Start:::::::::::::::::::::::::::::::::::::
:start
taskkill /IM v* /F
set /p minutes="Enter the number of minutes for the timer: "
:: Convert minutes to seconds
set /a seconds=%minutes%*60
:loop
cls
set /a mins_left=seconds/60
set /a secs_left=seconds%%60
echo Timer: %mins_left%:%secs_left%
timeout /t 1 >nul
set /a seconds=seconds-1
if %seconds% gtr 0 goto loop

:: Start the timer
echo Timer set for %minutes% minute(s). Press Ctrl+C to cancel.
timeout /t %seconds% /nobreak
:: Notify when time is up
:: the line below comment iy
::"E:\Vids All\allah.webm"
"D:\Data\Videos\فيديوهات عامة\إزاي تطول عمرك 10 سنين؟(360P).mp4"

echo 1. to complete Timer
echo 0 to end Timer
set /p choice=Enter your choice (0-1): 
if "%choice%"=="1" goto start
if "%choice%"=="2" goto :end
:::::::::::::::::::::::::::::::::::::::::::End::::::::::::::::::::::::::::::::::::::::::
:end
taskkill /IM v* /F
echo Goodbye!
pause
exit


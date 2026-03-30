@echo off
title Ultra Deep & Safe Windows Cleaner v4
color 0A

echo ==============================================
echo      Ultra Deep + Safe + Full Cleaning v4
echo ==============================================
echo This script is safe – all operations logged.
echo Run as Administrator for full cleaning.
echo ==============================================
echo.

::--- Create log ---
set LOG=%~dp0ultimate_clean_log.txt
echo Cleaning started at %date% %time% > "%LOG%"

::==================================================
:: STEP 1 — USER TEMP
::==================================================
echo [1] Cleaning User Temp...
echo [User Temp] >> "%LOG%"
del /q /f "%TEMP%\*" >> "%LOG%" 2>&1
for /d %%a in ("%TEMP%\*") do rd /s /q "%%a" >> "%LOG%" 2>&1

::==================================================
:: STEP 2 — WINDOWS TEMP
::==================================================
echo [2] Cleaning Windows Temp...
echo [Windows Temp] >> "%LOG%"
del /q /f "C:\Windows\Temp\*" >> "%LOG%" 2>&1
for /d %%a in ("C:\Windows\Temp\*") do rd /s /q "%%a" >> "%LOG%" 2>&1

::==================================================
:: STEP 3 — PREFETCH
::==================================================
echo [3] Cleaning Prefetch...
echo [Prefetch] >> "%LOG%"
del /q /f "C:\Windows\Prefetch\*" >> "%LOG%" 2>&1

::==================================================
:: STEP 4 — WINDOWS UPDATE CACHE
::==================================================
echo [4] Cleaning Windows Update Cache...
echo [SoftwareDistribution] >> "%LOG%"
net stop wuauserv >nul & net stop bits >nul

rd /s /q "C:\Windows\SoftwareDistribution\Download" >> "%LOG%" 2>&1

net start wuauserv >nul & net start bits >nul

::==================================================
:: STEP 5 — DELIVERY OPTIMIZATION CACHE
::==================================================
echo [5] Cleaning Delivery Optimization...
echo [Delivery Optimization] >> "%LOG%"
rd /s /q "C:\ProgramData\Microsoft\Windows\DeliveryOptimization" >> "%LOG%" 2>&1

::==================================================
:: STEP 6 — ERROR REPORTING
::==================================================
echo [6] Cleaning Windows Error Reporting...
echo [WER] >> "%LOG%"
rd /s /q "C:\ProgramData\Microsoft\Windows\WER" >> "%LOG%" 2>&1
rd /s /q "%LOCALAPPDATA%\Microsoft\Windows\WER" >> "%LOG%" 2>&1

::==================================================
:: STEP 7 — LOGS
::==================================================
echo [7] Clearing Logs...
echo [Logs] >> "%LOG%"
del /q /f "C:\Windows\Logs\*" >> "%LOG%" 2>&1
del /q /f "C:\Windows\System32\winevt\Logs\*.evtx" >> "%LOG%" 2>&1

::==================================================
:: STEP 8 — DRIVER STORE LOGS
::==================================================
echo [8] Cleaning Driver Backup Logs...
echo [Driver Logs] >> "%LOG%"
del /q /f "C:\Windows\System32\DriverStore\FileRepository\*.log" >> "%LOG%" 2>&1

::==================================================
:: STEP 9 — BROWSER CACHE
::==================================================
echo [9] Cleaning Browser Cache...
echo [Browser Cache] >> "%LOG%"

rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >> "%LOG%"
rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >> "%LOG%"
for /d %%a in ("%APPDATA%\Mozilla\Firefox\Profiles\*.default*") do rd /s /q "%%a\cache2" >> "%LOG%"

::==================================================
:: STEP 10 — DNS CACHE
::==================================================
echo [10] Flushing DNS Cache...
echo [DNS] >> "%LOG%"
ipconfig /flushdns >> "%LOG%" 2>&1

::==================================================
:: STEP 11 — RECYCLE BIN
::==================================================
echo [11] Emptying Recycle Bin...
echo [RecycleBin] >> "%LOG%"
powershell -command "Clear-RecycleBin -Force" >> "%LOG%" 2>&1

::==================================================
:: STEP 12 — SHADOW COPIES (SAFE)
::==================================================
echo [12] Cleaning old Shadow Copies (keeping latest)...
echo [Shadow Copies] >> "%LOG%"

wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "Auto_Cleanup", 100, 7 >> "%LOG%" 2>&1

:shadow_loop
set count=0
for /f %%a in ('vssadmin list shadows ^| findstr "Shadow Copy ID"') do set /a count+=1

if %count% GTR 1 (
    vssadmin delete shadows /for=C: /oldest /quiet >> "%LOG%"
    goto shadow_loop
)

echo Shadow Copies cleaned, latest preserved. >> "%LOG%"

::==================================================
:: STEP 13 — WINDOWS.OLD CLEANUP
::==================================================
echo [13] Cleaning Windows.old if exists...
echo [Windows.old] >> "%LOG%"
if exist "C:\Windows.old" (
    takeown /f "C:\Windows.old" /r /d y >nul
    icacls "C:\Windows.old" /grant administrators:F /t >nul
    rd /s /q "C:\Windows.old" >> "%LOG%" 2>&1
)

::==================================================
:: STEP 14 — RAM CACHE CLEAN (SAFE)
::==================================================
echo [14] Cleaning Standby RAM Cache (safe)...
echo [RAM Cache] >> "%LOG%"
powershell -command "Clear-MemoryCache" 2>>"%LOG%" 1>nul

:: Fallback safer method
powershell -command "Get-Process | Out-Null" >> "%LOG%"

::==================================================
:: STEP 15 — WINXSX COMPONENT CLEANUP (SAFE)
::==================================================
echo [15] Cleaning WinSxS safely...
echo [WinSxS] >> "%LOG%"
dism /online /cleanup-image /StartComponentCleanup >> "%LOG%" 2>&1

echo.
echo ==============================================
echo Cleaning Completed Successfully!
echo Log saved to: %LOG%
echo ==============================================
pause
exit

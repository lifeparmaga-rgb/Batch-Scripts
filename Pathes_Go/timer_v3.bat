:: ============================================================
:: المزايا الجديدة
:: ------------------------------------------------------------
:: بعد انتهاء الوقت الأساسي:
:: - يبدأ عدّ الوقت الزائد (Overtime) تلقائيًا
:: - يعرض:
::   * الوقت المحدد
::   * الوقت الزائد
::   * الوقت الكلي
::
:: ------------------------------------------------------------
:: تسجيل الإنتاجية:
:: - إنشاء ملف يومي باسم التاريخ
:: - تجميع ساعات الإنتاج اليومي
::
:: ------------------------------------------------------------
:: قائمة الاختيارات بعد الانتهاء:
:: 1 - إعادة تشغيل التايمر من جديد
:: 2 - إضافة وقت عمل إضافي (غفوة) + إعادة تشغيل النغمة
:: 3 - خروج من البرنامج
::
:: ------------------------------------------------------------
:: التنبيهات الصوتية:
:: - تشغيل النغمة عند انتهاء الوقت
:: - إعادة النغمة بعد انتهاء الغفوة
::
:: ------------------------------------------------------------
:: ملف التسجيل:
:: logs\productivity_YYYY-MM-DD.log
::
:: يتم تسجيل:
:: Start Time:
:: Planned Time:
:: Overtime:
:: Total Time:
:: ---------------------
:: ============================================================

@echo off
title Production Timer
setlocal EnableDelayedExpansion

:: ================== إعدادات ==================
set SOUND_FILE=D:\Data\Audios\050.mp3
set LOG_DIR=logs
:: ============================================

if not exist "%SOUND_FILE%" (
    echo Sound file not found!
    pause
    exit /b
)

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

:: ====== إدخال الوقت ======
set /p MINUTES=Enter Work Time (Minutes): 

for /f "delims=0123456789" %%a in ("%MINUTES%") do (
    echo Invalid Input
    pause
    exit /b
)

set /a TARGET_SECONDS=MINUTES*60
set TOTAL_SECONDS=%TARGET_SECONDS%
set OVERTIME=0

set START_TIME=%TIME%
set DATE_STR=%DATE:/=-%
set LOG_FILE=%LOG_DIR%\productivity_%DATE_STR%.log

:: ====== العد التنازلي ======
:COUNTDOWN
cls
set /a M=TOTAL_SECONDS/60
set /a S=TOTAL_SECONDS%%60

if %S% LSS 10 (
    echo Remaining: %M%:0%S%
) else (
    echo Remaining: %M%:%S%
)

if %TOTAL_SECONDS% LEQ 0 goto OVERTIME_START

set /a TOTAL_SECONDS-=1
timeout /t 1 /nobreak >nul
goto COUNTDOWN

:: ====== وقت إضافي ======
:OVERTIME_START
start "" "%SOUND_FILE%"
cls
echo ⏰ Time Finished – Overtime Started
timeout /t 1 >nul

:OVERTIME_LOOP
cls
set /a OVERTIME+=1
set /a OM=OVERTIME/60
set /a OS=OVERTIME%%60

if %OS% LSS 10 (
    echo Overtime: %OM%:0%OS%
) else (
    echo Overtime: %OM%:%OS%
)

timeout /t 1 /nobreak >nul
choice /c ABC /n /t 1 /d A >nul
goto OVERTIME_LOOP

:: ====== القائمة ======
:MENU
cls
echo ===== Work Session Finished =====
echo Planned Time : %MINUTES% Minutes
echo Overtime     : %OM%:%OS%
set /a TOTAL_TIME=TARGET_SECONDS+OVERTIME
set /a TM=TOTAL_TIME/60
set /a TS=TOTAL_TIME%%60
echo Total Time   : %TM%:%TS%
echo.
echo 1 - Restart Timer
echo 2 - Add Extra Work Time
echo 3 - Exit
choice /c 123

if errorlevel 3 goto SAVE_EXIT
if errorlevel 2 goto ADD_TIME
if errorlevel 1 goto RESTART

:: ====== إضافة وقت ======
:ADD_TIME
set /p EXTRA=Extra Minutes: 
set /a TOTAL_SECONDS=EXTRA*60
set OVERTIME=0
start "" "%SOUND_FILE%"
goto COUNTDOWN

:: ====== إعادة تشغيل ======
:RESTART
call "%~f0"
exit /b

:: ====== حفظ والخروج ======
:SAVE_EXIT
(
echo Start Time : %START_TIME%
echo Planned   : %MINUTES% Minutes
echo Overtime  : %OM%:%OS%
echo Total     : %TM%:%TS%
echo --------------------------
)>>"%LOG_FILE%"

echo Session Saved.
pause
exit

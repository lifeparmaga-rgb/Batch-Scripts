
:: =========================================================
::                 باتش سمريبت - File Explorer
:: =========================================================
:: المميزات الموجودة:
:: ✔ واجهة مرتبة وألوان جميلة
:: ✔ دعم كامل للغة العربية
:: ✔ عرض الملفات والمجلدات
:: ✔ الدخول للمجلدات الفرعية
:: ✔ الرجوع للخلف بسهولة
:: ✔ البحث داخل جميع المجلدات
:: ✔ تحديث تلقائي للقائمة
:: ✔ إظهار أي ملف جديد تلقائيًا
:: ✔ فتح جميع أنواع الملفات والبرامج
:: =========================================================
@echo off
chcp 65001 >nul
title مدير الملفات الاحترافي
mode con: cols=90 lines=30
color 0B

setlocal EnableDelayedExpansion

:: ==========================================
:: ضع مسار المجلد الرئيسي هنا
:: ==========================================
set "ROOT=D:\OBS\00- Dashboard_Parmaga_Links_Only_2026\All Needed Files Folders\03- AI Ask + Filter"

:: المجلد الحالي
set "CURRENT=%ROOT%"

:MAIN
cls

echo.
echo  ============================================================
echo                    مدير الملفات الاحترافي
echo  ============================================================
echo.
echo  المجلد الحالي:
echo  %CURRENT%
echo.
echo  ------------------------------------------------------------
echo.

set count=0

:: عرض المجلدات أولاً
for /d %%D in ("%CURRENT%\*") do (
    set /a count+=1
    set "item!count!=%%D"
    set "type!count!=DIR"
    echo   [!count!] 📁 %%~nxD
)

:: عرض الملفات
for %%F in ("%CURRENT%\*") do (
    if not "%%~aF"=="d" (
        set /a count+=1
        set "item!count!=%%F"
        set "type!count!=FILE"
        echo   [!count!] 📄 %%~nxF
    )
)

echo.
echo  ------------------------------------------------------------
echo.
echo   [B] Back to Previous Folder
echo   [S] Search for File
echo   [R] Refresh
echo   [Q] Quit
echo.

set /p choice= اختر رقم أو أمر: 

:: ==========================================
:: خروج
:: ==========================================
if /I "%choice%"=="Q" exit

:: ==========================================
:: تحديث
:: ==========================================
if /I "%choice%"=="R" goto MAIN

:: ==========================================
:: رجوع
:: ==========================================
if /I "%choice%"=="B" (
    if /I not "%CURRENT%"=="%ROOT%" (
        for %%A in ("%CURRENT%\..") do set "CURRENT=%%~fA"
    )
    goto MAIN
)

:: ==========================================
:: البحث
:: ==========================================
if /I "%choice%"=="S" goto SEARCH

:: ==========================================
:: فتح عنصر
:: ==========================================
if defined item%choice% (

    if "!type%choice%!"=="DIR" (
        set "CURRENT=!item%choice%!"
        goto MAIN
    )

    if "!type%choice%!"=="FILE" (
        start "" "!item%choice%!"
        goto MAIN
    )
)

echo.
echo  اختيار غير صحيح
timeout /t 2 >nul
goto MAIN

:: ==========================================
:: البحث
:: ==========================================
:SEARCH
cls
echo.
echo  ================= البحث =================
echo.

set /p keyword= اكتب اسم الملف أو جزء منه: 

cls
echo.
echo  نتائج البحث:
echo.
echo  ------------------------------------------------------------
echo.

set found=0
set searchcount=0

for /r "%ROOT%" %%F in (*) do (
    echo %%~nxF | find /I "%keyword%" >nul
    if not errorlevel 1 (
        set /a searchcount+=1
        set "search!searchcount!=%%F"
        echo   [!searchcount!] %%~nxF
        set found=1
    )
)

echo.
echo  ------------------------------------------------------------
echo.

if "%found%"=="0" (
    echo  لا توجد نتائج
    pause
    goto MAIN
)

echo.
echo   [0] رجوع
echo.

set /p openchoice= اختر رقم الملف لفتحه: 

if "%openchoice%"=="0" goto MAIN

if defined search%openchoice% (
    start "" "!search%openchoice%!"
)

goto MAIN
@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: الانتقال لمكان السكربت
cd /d "%~dp0"

:: جلب التاريخ بصيغة YYYY-MM-DD
for /f "tokens=2 delims==." %%A in ('wmic os get localdatetime /value') do set dt=%%A
set year=%dt:~0,4%
set month=%dt:~4,2%
set day=%dt:~6,2%
set date=%year%-%month%-%day%

:: جلب رقم اليوم (0=الأحد)
for /f %%D in ('powershell -command "(Get-Date).DayOfWeek.value__"') do set dow=%%D

:: تحويل رقم اليوم إلى اسم عربي
if %dow%==0 set dayname=الأحد
if %dow%==1 set dayname=الإثنين
if %dow%==2 set dayname=الثلاثاء
if %dow%==3 set dayname=الأربعاء
if %dow%==4 set dayname=الخميس
if %dow%==5 set dayname=الجمعة
if %dow%==6 set dayname=السبت

:: إنشاء المجلد
mkdir "%date% - %dayname%"

echo تم إنشاء المجلد: %date% - %dayname%
pause
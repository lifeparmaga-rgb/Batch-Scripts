@echo off
chcp 65001 >nul

:: المجلد الحالي المراد عمل رابط له
set TARGET=%cd%

:: مكان إنشاء الرابط
set DEST=D:\OBS\Folder_Shortcuts

:: اسم الرابط
set /p NAME=Enter link name: 

:: إنشاء Junction
mklink /J "%DEST%\%NAME%" "%TARGET%"

echo.
echo Junction created successfully.
pause
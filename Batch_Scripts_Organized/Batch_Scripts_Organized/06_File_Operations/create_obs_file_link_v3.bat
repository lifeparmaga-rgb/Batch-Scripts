@echo off
set /p NAME=Enter shortcut name: 

:: الفولدر الحالي
set TARGET=%cd%

:: مكان إنشاء الاختصار (في نفس مكان ملف البات)
set SHORTCUT=%~dp0%NAME%.lnk

powershell -NoProfile -Command ^
"$WshShell = New-Object -ComObject WScript.Shell; ^
$Shortcut = $WshShell.CreateShortcut('%SHORTCUT%'); ^
$Shortcut.TargetPath = '%TARGET%'; ^
$Shortcut.WorkingDirectory = '%TARGET%'; ^
$Shortcut.Save()"

echo.
echo Shortcut "%NAME%" created successfully.
pause
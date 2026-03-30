@echo off
setlocal EnableDelayedExpansion

:: تحقق من المسار
set "FOLDER=%~1"
if "%FOLDER%"=="" (
    echo Usage: Right-click on a folder -> Change Icon
    exit /b
)

:: اختيار ملف (ICO أو PNG)
for /f "delims=" %%I in ('powershell -NoProfile -Command ^
"Add-Type -AssemblyName System.Windows.Forms; ^
$fd = New-Object System.Windows.Forms.OpenFileDialog; ^
$fd.Filter = 'Image Files (*.ico;*.png)|*.ico;*.png'; ^
if($fd.ShowDialog() -eq 'OK'){ $fd.FileName }"') do set "FILE=%%I"

if not defined FILE exit /b

:: تعيين المسار النهائي للأيقونة داخل المجلد
set "ICO_PATH=%FOLDER%\folder.ico"

:: إذا كانت PNG → تحويل تلقائي إلى ICO
for %%X in ("%FILE%") do (
    set "EXT=%%~xX"
)

if /I "%EXT%"==".png" (
    echo Converting PNG to ICO...
    powershell -NoProfile -Command ^
    "Add-Type -AssemblyName System.Drawing; ^
    $img = [System.Drawing.Image]::FromFile('%FILE%'); ^
    $bmp = New-Object System.Drawing.Bitmap $img, 256,256; ^
    $bmp.Save('%ICO_PATH%', [System.Drawing.Imaging.ImageFormat]::Icon);"
) else (
    copy "%FILE%" "%ICO_PATH%" /Y >nul
)

:: إنشاء desktop.ini
(
echo [.ShellClassInfo]
echo IconResource=folder.ico,0
) > "%FOLDER%\desktop.ini"

:: ضبط الخصائص
attrib +s +h "%FOLDER%\desktop.ini"
attrib +s "%FOLDER%"

:: تحديث Explorer بدون إعادة تشغيل كاملة
taskkill /im explorer.exe /f >nul 2>&1
start explorer.exe

echo Done! Icon applied to folder.
pause
endlocal

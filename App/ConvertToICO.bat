@echo off
title Image to ICO Converter (256x256)
color 0a
echo ===========================================
echo     تحويل أي صورة إلى أيقونة ICO (256x256)
echo ===========================================
echo.
echo - تقدر تسحب الصورة هنا مباشرة
echo - أو تكتب مسار الصورة ثم Enter
echo.

set /p IMG="Image path: "

if "%IMG%"=="" (
    echo Drag and drop an image file on this window...
    pause
    exit /b
)

set SCRIPT="%~dp0AnyImageToICO.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File %SCRIPT% "%IMG%"

echo.
echo انتهى التحويل! اضغط أي زر للخروج.
pause >nul

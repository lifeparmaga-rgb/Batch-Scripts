@echo off
setlocal enabledelayedexpansion

:: إنشاء فولدر output لو مش موجود
if not exist "output" mkdir "output"

:: قائمة الامتدادات المدعومة (تقدر تزود أو تعدل)
set formats=png jpg jpeg bmp gif tif tiff webp ico svg heic

set found=0

for %%e in (%formats%) do (
    for %%i in (*%%e) do (
        set found=1
        echo Converting: %%i
        magick "%%i" -define icon:auto-resize=256,128,64,48,32,16 "output/%%~ni.ico"
    )
)

if %found%==0 (
    echo No supported images found!
) else (
    echo Done!
)

pause
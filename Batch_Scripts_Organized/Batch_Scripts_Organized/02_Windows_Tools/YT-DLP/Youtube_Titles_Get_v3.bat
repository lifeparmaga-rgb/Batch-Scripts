@echo off
chcp 65001 >nul
title YouTube Playlist Titles Extractor

:: مسار السكربت
set BASE_DIR=%~dp0
set OUTPUT_DIR=%BASE_DIR%Playlists_Titles

:: إنشاء المجلد إن لم يكن موجود
if not exist "%OUTPUT_DIR%" (
    mkdir "%OUTPUT_DIR%"
)

echo ================================
echo   YouTube Playlist Extractor
echo ================================
echo.

:: طلب اللينك
set /p YT_LINK=Enter YouTube Playlist Link: 

if "%YT_LINK%"=="" (
    echo.
    echo ❌ No link entered!
    pause
    exit /b
)

echo.
echo ⏳ Getting playlist name...

:: جلب اسم قائمة التشغيل
for /f "delims=" %%A in ('yt-dlp --get-playlist-title "%YT_LINK%"') do (
    set PLAYLIST_NAME=%%A
)

:: تأخير متغيرات
setlocal EnableDelayedExpansion

:: تنظيف الاسم من الرموز غير المسموح بها في الويندوز
set FILE_NAME=!PLAYLIST_NAME!
set FILE_NAME=!FILE_NAME:\=!
set FILE_NAME=!FILE_NAME:/=!
set FILE_NAME=!FILE_NAME::=!
set FILE_NAME=!FILE_NAME:?=!
set FILE_NAME=!FILE_NAME:"=!
set FILE_NAME=!FILE_NAME:^<=!
set FILE_NAME=!FILE_NAME:^>=!
set FILE_NAME=!FILE_NAME:|=!

set FILE_PATH=%OUTPUT_DIR%\!FILE_NAME!.txt

echo.
echo 📁 Folder  : %OUTPUT_DIR%
echo 📄 File    : !FILE_NAME!.txt
echo.

:: كتابة البيانات
echo Playlist: !PLAYLIST_NAME! > "!FILE_PATH!"
echo Link: %YT_LINK% >> "!FILE_PATH!"
echo Date: %DATE% %TIME% >> "!FILE_PATH!"
echo. >> "!FILE_PATH!"

:: استخراج العناوين
yt-dlp --get-title --playlist-reverse "%YT_LINK%" >> "!FILE_PATH!"

echo.
echo ✅ Done Successfully!
echo.

:: فتح الملف
start notepad "!FILE_PATH!"

pause
exit

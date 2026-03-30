@echo off
chcp 65001 >nul
title YouTube Titles Extractor

set FILE=youtube_titles.txt

echo ================================
echo   YouTube Titles Extractor
echo ================================
echo.

:: طلب اللينك
set /p YT_LINK=Enter YouTube Link (Video or Playlist): 

if "%YT_LINK%"=="" (
    echo.
    echo ❌ No link entered!
    pause
    exit /b
)

echo.
echo ====== Start ======= >> "%FILE%"
echo Link: %YT_LINK% >> "%FILE%"
echo Date: %DATE% %TIME% >> "%FILE%"
echo. >> "%FILE%"

:: تحميل العناوين
yt-dlp --get-title --playlist-reverse "%YT_LINK%" >> "%FILE%"

echo. >> "%FILE%"
echo ====== End ======= >> "%FILE%"
echo. >> "%FILE%"
echo. >> "%FILE%"

echo ✅ Done! Titles saved in %FILE%
echo.

:: فتح الملف بعد الانتهاء
start notepad "%FILE%"

exit

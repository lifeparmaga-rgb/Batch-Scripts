@echo off
setlocal enabledelayedexpansion

:: طلب إدخال النص
set /p text=Enter Text You Want Translate It

:: تحديد اللغة الهدف
echo Select Target Language
echo 1. Arabic
echo 2. English
set /p lang_choice= Enter Choose   

:: تحديد كود اللغة
if "%lang_choice%"=="1" (
    set target_lang=ar
) else if "%lang_choice%"=="2" (
    set target_lang=en
) else (
    echo Invalid Choose, Will Translate Into English As Default
    set target_lang=en
)

:: ترميز النص ليصلح لرابط URL (استبدال المسافات بـ %20 وغيرها)
set "encoded_text=%text%"
set "encoded_text=%encoded_text: =%%20%"

:: فتح الرابط في المتصفح Microsoft Edge
start msedge.exe "https://translate.google.com/?sl=auto&tl=%target_lang%&text=%encoded_text%&op=translate"

exit

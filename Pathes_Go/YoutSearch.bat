@echo off
:: اسأل المستخدم عن كلمة البحث
set /p search="ادخل كلمة البحث على يوتيوب: "

:: استبدال الفراغات بـ + علشان رابط البحث
set search=%search: =+%

:: فتح الرابط في المتصفح الافتراضي
start "" "https://www.youtube.com/results?search_query=%search%"

:: إنهاء البرنامج
exit

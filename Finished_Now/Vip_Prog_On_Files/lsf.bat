@echo off
setlocal enabledelayedexpansion

:: اسم الملف الناتج
set "output=files_list.txt"

:: إنشاء الملف في المجلد الحالي
(
    echo ملفات المجلد الحالي:
    echo =====================
    
    for %%F in (*) do (
        echo %%F
    )
) > "%output%"

:: فتح الملف بعد الإنشاء
start "" "%output%"

echo تم إنشاء الملف: %output%
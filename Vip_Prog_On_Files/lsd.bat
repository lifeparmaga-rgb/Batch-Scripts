@echo off
setlocal enabledelayedexpansion

:: اسم الملف الناتج
set "output=files_list.txt"

:: امسح الملف لو موجود
if exist "%output%" del "%output%"

:: ابدأ من المجلد الحالي
call :process_folder "%cd%"

:: افتح الملف بعد الانتهاء
start "" "%output%"

echo Done!
pause
exit /b

:: =========================
:process_folder
set "current_folder=%~1"

:: اكتب اسم المجلد بعلامة مميزة
echo ============================== >> "%output%"
echo [FOLDER] %current_folder% >> "%output%"
echo ============================== >> "%output%"

:: اكتب الملفات داخل المجلد
for %%f in ("%current_folder%\*") do (
    if not "%%~ff"=="%output%" (
        if not exist "%%f\" (
            echo     %%~nxf >> "%output%"
        )
    )
)

:: لف على المجلدات الفرعية
for /d %%d in ("%current_folder%\*") do (
    call :process_folder "%%d"
)

exit /b
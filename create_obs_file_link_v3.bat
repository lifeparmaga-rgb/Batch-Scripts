@echo off
setlocal enabledelayedexpansion

set "input=files_list.txt"
set "output=dashboard.txt"

if exist "%output%" del "%output%"

echo # Dashboard >> "%output%"
echo. >> "%output%"

for /f "usebackq delims=" %%a in ("%input%") do (
    set "line=%%a"

    :: حذف [FOLDER]
    set "line=!line:[FOLDER]=!"

    :: Trim من البداية
    for /f "tokens=* delims= " %%b in ("!line!") do set "line=%%b"

    :: Trim من النهاية (loop آمن داخل نفس البلوك)
    call :trimEnd line

    :: تجاهل الفاضي و =====
    if not "!line!"=="" (
        echo !line! | findstr "=" >nul
        if errorlevel 1 (
            echo - # [[!line!]]>>"%output%"
        )
    )
)

start "" "%output%"
echo Done!
pause
exit /b

:trimEnd
setlocal enabledelayedexpansion
set "str=!%1!"
:loop
if "!str:~-1!"==" " (
    set "str=!str:~0,-1!"
    goto loop
)
endlocal & set "%1=%str%"
exit /b
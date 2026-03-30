@echo off
setlocal EnableDelayedExpansion

REM Set table column widths
set "col1=30"
set "col2=12"
set "col3=20"

REM Print table header with borders
call :printLine "+"
echo|set /p="| Name                          | Size (KB)   | Modified Date       |"
call :printLine "+"

REM Loop through files and folders
for /f "delims=" %%F in ('dir /b') do (
    set "name=%%F"

    REM Get file info
    for /f "tokens=1-5*" %%a in ('dir "%%F" ^| find "%%F"') do (
        set "rawsize=%%d"
        set "date=%%a %%b"

        REM Handle <DIR> display
        if "!rawsize!"=="<DIR>" (
            set "size=<DIR>"
        ) else (
            set /a size=!rawsize!
        )

        REM Format columns with padding
        call :padRight "!name!" 30 nameOut
        call :padRight "!size!" 12 sizeOut
        call :padRight "!date!" 20 dateOut

        REM Output row with padding
        echo|set /p="| !nameOut!| !sizeOut!| !dateOut!|"
    )
)

REM Print bottom border
call :printLine "+"

pause
exit /b

REM =============================
:padRight
setlocal
set "str=%~1"
set "len=%~2"

REM Pad string to desired length
set "result=!str!                                                               "
set "result=!result:~0,%len%!"
endlocal & set "%~3=%result%"
exit /b

:printLine
setlocal
set "line=%~1"
for /l %%i in (1,1,30) do set "line=%line%-"
set "line=%line%+"
for /l %%i in (1,1,12) do set "line=%line%-"
set "line=%line%+"
for /l %%i in (1,1,20) do set "line=%line%-"
set "line=%line%+"
echo %line%
endlocal
exit /b

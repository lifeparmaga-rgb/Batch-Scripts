@echo off
setlocal enabledelayedexpansion
color 0A
title SearchPro

set "LOGFILE=%~dp0SearchResults.txt"
set "DEFAULT_PATH=%CD%"

:MAIN_MENU
cls
call :DRAW_HEADER
echo.
echo   ====================================================
echo                     MAIN MENU
echo   ====================================================
echo     [1] Search for text inside file contents
echo     [2] Search for files by name
echo     [3] Advanced search (extension + text + case)
echo     [4] Show last saved search results
echo     [5] Clear results file
echo     [0] Exit
echo   ====================================================
set /p "CHOICE=Enter your choice: "

if "%CHOICE%"=="1" goto SEARCH_CONTENT
if "%CHOICE%"=="2" goto SEARCH_FILENAME
if "%CHOICE%"=="3" goto SEARCH_ADVANCED
if "%CHOICE%"=="4" goto SHOW_LOG
if "%CHOICE%"=="5" goto CLEAR_LOG
if "%CHOICE%"=="0" goto END
echo Invalid choice, try again...
pause
goto MAIN_MENU

:: =====================================================
:: 1) Search text inside files
:: =====================================================
:SEARCH_CONTENT
cls
set "SPATH="
set /p "SPATH=Folder path to search (leave empty for current folder): "
if "%SPATH%"=="" set "SPATH=%DEFAULT_PATH%"

if not exist "%SPATH%" (
    echo Path does not exist: %SPATH%
    pause
    goto MAIN_MENU
)

set "KEYWORD="
set /p "KEYWORD=Text to search for: "
if "%KEYWORD%"=="" (
    echo No search text entered.
    pause
    goto MAIN_MENU
)

echo Searching for "%KEYWORD%" inside: %SPATH%

> "%LOGFILE%" (
    echo Search results for text: %KEYWORD%
    echo Path: %SPATH%
    echo Date: %DATE% %TIME%
    echo ====================================================
)

set "FOUND=0"
for /r "%SPATH%" %%F in (*.*) do (
    findstr /n /i /c:"%KEYWORD%" "%%F" >nul 2>&1
    if !errorlevel! equ 0 (
        set /a FOUND+=1
        echo Found in: %%F
        echo --- %%F --- >> "%LOGFILE%"
        findstr /n /i /c:"%KEYWORD%" "%%F" >> "%LOGFILE%" 2>nul
        echo. >> "%LOGFILE%"
    )
)

if %FOUND% gtr 0 (
    echo Done. Matching files: %FOUND%
    echo Full details saved in: %LOGFILE%
) else (
    echo No results found.
)
pause
goto MAIN_MENU

:: =====================================================
:: 2) Search by filename
:: =====================================================
:SEARCH_FILENAME
cls
set "SPATH="
set /p "SPATH=Folder path to search (leave empty for current folder): "
if "%SPATH%"=="" set "SPATH=%DEFAULT_PATH%"

if not exist "%SPATH%" (
    echo Path does not exist.
    pause
    goto MAIN_MENU
)

set "FNAME="
set /p "FNAME=File name or part of it (you can use * and ?): "
if "%FNAME%"=="" set "FNAME=*"

echo Searching...

> "%LOGFILE%" (
    echo Search results for filename: %FNAME%
    echo Path: %SPATH%
    echo Date: %DATE% %TIME%
    echo ====================================================
)

set "FOUND=0"
for /r "%SPATH%" %%F in (*%FNAME%*) do (
    set /a FOUND+=1
    echo %%F
    echo %%F >> "%LOGFILE%"
)

if %FOUND% gtr 0 (
    echo Found %FOUND% matching files.
    echo List saved in: %LOGFILE%
) else (
    echo No matching files.
)
pause
goto MAIN_MENU

:: =====================================================
:: 3) Advanced search
:: =====================================================
:SEARCH_ADVANCED
cls
set "SPATH="
set /p "SPATH=Folder path (empty = current folder): "
if "%SPATH%"=="" set "SPATH=%DEFAULT_PATH%"

if not exist "%SPATH%" (
    echo Path does not exist.
    pause
    goto MAIN_MENU
)

set "EXT="
set /p "EXT=File extension (example: txt or log, empty = all): "
if "%EXT%"=="" (set "MASK=*.*") else (set "MASK=*.%EXT%")

set "KEYWORD="
set /p "KEYWORD=Text to search for: "
if "%KEYWORD%"=="" (
    echo You must enter search text.
    pause
    goto MAIN_MENU
)

set "CASE="
set /p "CASE=Case sensitive search? (y/n): "
if /i "%CASE%"=="y" (set "CFLAG=") else (set "CFLAG=/i")

echo Searching for "%KEYWORD%" in files (%MASK%)...

> "%LOGFILE%" (
    echo Advanced search - Text: %KEYWORD%  ^| Extension: %MASK%  ^| Case sensitive: %CASE%
    echo Path: %SPATH%
    echo Date: %DATE% %TIME%
    echo ====================================================
)

set "FOUND=0"
for /r "%SPATH%" %%F in (%MASK%) do (
    findstr /n %CFLAG% /c:"%KEYWORD%" "%%F" >nul 2>&1
    if !errorlevel! equ 0 (
        set /a FOUND+=1
        echo Found in: %%F
        echo --- %%F --- >> "%LOGFILE%"
        findstr /n %CFLAG% /c:"%KEYWORD%" "%%F" >> "%LOGFILE%" 2>nul
        echo. >> "%LOGFILE%"
    )
)

if %FOUND% gtr 0 (
    echo Matching files: %FOUND%
    echo Details saved in: %LOGFILE%
) else (
    echo No matching results.
)
pause
goto MAIN_MENU

:: =====================================================
:: 4) Show last results
:: =====================================================
:SHOW_LOG
cls
if exist "%LOGFILE%" (
    type "%LOGFILE%"
) else (
    echo No saved results file yet.
)
pause
goto MAIN_MENU

:: =====================================================
:: 5) Clear results file
:: =====================================================
:CLEAR_LOG
if exist "%LOGFILE%" del /q "%LOGFILE%"
echo Results file cleared successfully.
pause
goto MAIN_MENU

:: =====================================================
:: Header function
:: =====================================================
:DRAW_HEADER
echo   ====================================================
echo              S E A R C H   P R O
echo   ====================================================
exit /b

:END
cls
echo Thanks for using SearchPro
pause
endlocal

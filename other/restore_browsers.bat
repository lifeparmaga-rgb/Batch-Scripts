@echo off
:: Restore script for browser favorites
:: Define the backup folder
set BACKUP_DIR=%USERPROFILE%\Documents\Browser_Favorites_Backup

:: Check if the backup directory exists
if not exist "%BACKUP_DIR%" (
    echo Backup directory not found: "%BACKUP_DIR%"
    pause
    exit /b
)

:: Define paths to common browsers' bookmark locations
set CHROME_BOOKMARKS=%LOCALAPPDATA%\Google\Chrome\User Data\Default\Bookmarks
set EDGE_BOOKMARKS=%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Bookmarks
set FIREFOX_PROFILE_DIR=%APPDATA%\Mozilla\Firefox\Profiles

:: Prompt the user to select a browser to restore bookmarks
:MENU
echo Select a browser to restore bookmarks:
echo 1. Google Chrome
echo 2. Microsoft Edge
echo 3. Mozilla Firefox
echo 4. Exit
set /p choice=Enter your choice (1-4):

if "%choice%"=="1" goto RESTORE_CHROME
if "%choice%"=="2" goto RESTORE_EDGE
if "%choice%"=="3" goto RESTORE_FIREFOX
if "%choice%"=="4" exit /b

echo Invalid choice. Please try again.
goto MENU

:RESTORE_CHROME
:: Find the latest Chrome backup
for /f "delims=" %%f in ('dir "%BACKUP_DIR%\Chrome_Bookmarks_*.json" /b /o-d') do (
    set LATEST_BACKUP=%%f
    goto RESTORE_CHROME_CONTINUE
)
echo No Chrome backups found in "%BACKUP_DIR%".
pause
exit /b

:RESTORE_CHROME_CONTINUE
copy "%BACKUP_DIR%\%LATEST_BACKUP%" "%CHROME_BOOKMARKS%" /y
if errorlevel 1 (
    echo Failed to restore Chrome bookmarks.
) else (
    echo Chrome bookmarks restored successfully.
)
pause
exit /b

:RESTORE_EDGE
:: Find the latest Edge backup
for /f "delims=" %%f in ('dir "%BACKUP_DIR%\Edge_Bookmarks_*.json" /b /o-d') do (
    set LATEST_BACKUP=%%f
    goto RESTORE_EDGE_CONTINUE
)
echo No Edge backups found in "%BACKUP_DIR%".
pause
exit /b

:RESTORE_EDGE_CONTINUE
copy "%BACKUP_DIR%\%LATEST_BACKUP%" "%EDGE_BOOKMARKS%" /y
if errorlevel 1 (
    echo Failed to restore Edge bookmarks.
) else (
    echo Edge bookmarks restored successfully.
)
pause
exit /b

:RESTORE_FIREFOX
:: Find the Firefox profile and latest backup
for /f "delims=" %%d in ('dir "%FIREFOX_PROFILE_DIR%\*" /ad /b') do (
    set FIREFOX_PROFILE=%%d
    goto RESTORE_FIREFOX_CONTINUE
)
echo No Firefox profiles found.
pause
exit /b

:RESTORE_FIREFOX_CONTINUE
for /f "delims=" %%f in ('dir "%BACKUP_DIR%\Firefox_Bookmarks_*.sqlite" /b /o-d') do (
    set LATEST_BACKUP=%%f
    goto RESTORE_FIREFOX_FILE
)
echo No Firefox backups found in "%BACKUP_DIR%".
pause
exit /b

:RESTORE_FIREFOX_FILE
copy "%BACKUP_DIR%\%LATEST_BACKUP%" "%FIREFOX_PROFILE_DIR%\%FIREFOX_PROFILE%\places.sqlite" /y
if errorlevel 1 (
    echo Failed to restore Firefox bookmarks.
) else (
    echo Firefox bookmarks restored successfully.
)
pause
exit /b

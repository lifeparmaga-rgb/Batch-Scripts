@echo off
:: Backup script for browser favorites
:: Define the backup folder
set BACKUP_DIR=%USERPROFILE%\Documents\Browser_Favorites_Backup

:: Create the backup directory if it doesn't exist
if not exist "%BACKUP_DIR%" (
    mkdir "%BACKUP_DIR%"
)

:: Get the current date and time for the backup file name
setlocal enabledelayedexpansion
for /f "tokens=2 delims==." %%I in ('"wmic os get localdatetime /value | findstr /r "LocalDateTime""') do set datetime=%%I
set DATE=!datetime:~0,8!
set TIME=!datetime:~8,6!
set TIMESTAMP=!DATE!_!TIME!

:: Define paths to common browsers' bookmark locations
set CHROME_BOOKMARKS=%LOCALAPPDATA%\Google\Chrome\User Data\Default\Bookmarks
set EDGE_BOOKMARKS=%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Bookmarks
set FIREFOX_PROFILE_DIR=%APPDATA%\Mozilla\Firefox\Profiles

:: Backup Chrome bookmarks
if exist "%CHROME_BOOKMARKS%" (
    copy "%CHROME_BOOKMARKS%" "%BACKUP_DIR%\Chrome_Bookmarks_!TIMESTAMP!.json"
    echo Chrome bookmarks backed up.
) else (
    echo Chrome bookmarks not found.
)

:: Backup Edge bookmarks
if exist "%EDGE_BOOKMARKS%" (
    copy "%EDGE_BOOKMARKS%" "%BACKUP_DIR%\Edge_Bookmarks_!TIMESTAMP!.json"
    echo Edge bookmarks backed up.
) else (
    echo Edge bookmarks not found.
)

:: Backup Firefox bookmarks
if exist "%FIREFOX_PROFILE_DIR%" (
    for /d %%d in ("%FIREFOX_PROFILE_DIR%\*") do if exist "%%d\places.sqlite" (
        copy "%%d\places.sqlite" "%BACKUP_DIR%\Firefox_Bookmarks_!TIMESTAMP!.sqlite"
        echo Firefox bookmarks backed up.
    )
) else (
    echo Firefox profiles not found.
)

:: Completion message
echo Backup completed. Files are saved in "%BACKUP_DIR%".
pause

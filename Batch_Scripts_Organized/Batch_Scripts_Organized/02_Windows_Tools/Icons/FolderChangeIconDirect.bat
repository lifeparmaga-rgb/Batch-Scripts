@echo off
title Folder Change Icon Direct
color 0A

:MENU
cls
echo ================================
echo  Folder Change Icon Context Menu
echo ================================
echo.
echo 1. Add "Change Icon" to Right-Click Menu
echo 2. Remove "Change Icon" from Right-Click Menu
echo 3. Exit
echo.
set /p choice=Choose an option [1-3]:

if "%choice%"=="1" goto ADD
if "%choice%"=="2" goto REMOVE
if "%choice%"=="3" exit
goto MENU

:ADD
echo Adding "Change Icon" option...
:: إضافة الخيار للـ Right-Click على المجلد
reg add "HKCR\Directory\shell\ChangeIcon" /ve /d "Change Icon" /f
reg add "HKCR\Directory\shell\ChangeIcon" /v "Icon" /d "imageres.dll,23" /f
reg add "HKCR\Directory\shell\ChangeIcon\command" /ve /d "powershell -Command \"param([string]$folder) start-process 'rundll32.exe' -ArgumentList 'shell32.dll,Options_RunDLL FolderOptions' -WorkingDirectory $folder\"" /f
echo Done! Right-click on any folder and select "Change Icon" to open the folder's icon dialog.
pause
goto MENU

:REMOVE
echo Removing "Change Icon" option...
reg delete "HKCR\Directory\shell\ChangeIcon" /f
echo Done! Option removed.
pause
goto MENU

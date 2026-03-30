@echo off
setlocal EnableDelayedExpansion

REM Print Header
echo Name                           Size (KB)      Modified Date
echo -----------------------------------------------

REM Loop through each file and folder
for /f "delims=" %%F in ('dir /b') do (
    set "name=%%F"
    
    REM Get size and date using 'for' and 'dir'
    for /f "tokens=1-5*" %%a in ('dir "%%F" ^| find "%%F"') do (
        set "size=%%d"
        set "date=%%a %%b"
        
        REM Format output (pad to fixed width)
        set "line=!name!                                "
        set "line=!line:~0,30!  !size! KB       !date!"
        echo !line!
    )
)

endlocal
pause

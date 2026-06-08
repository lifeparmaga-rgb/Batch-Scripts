@echo off
setlocal enabledelayedexpansion

:: Check if user provided a path, otherwise use current directory
set "target_path=."
if not "%~1"=="" set "target_path=%~1"

:: Loop through all .md files in the target directory
for /r "%target_path%" %%f in (*.md) do (
    echo Processing: %%f
    
    :: Create a temporary file
    set "temp_file=%%~dpnf_temp.md"
    
    :: Wrap entire file in <div dir="rtl">
    echo ^<div dir="rtl"^> > "!temp_file!"
    type "%%f" >> "!temp_file!"
    echo ^</div^> >> "!temp_file!"
    
    :: Process code blocks (replace ``` with ``` inside <div dir="ltr">)
    :: Using PowerShell for regex replacement
    powershell -Command "(Get-Content '!temp_file!') -replace '```([^\r\n]*)', '<div dir=\"ltr\">```$1' | Set-Content '!temp_file!'"
    powershell -Command "(Get-Content '!temp_file!') -replace '```', '```</div>' | Set-Content '%%f'"
    
    :: Clean up temp file
    del "!temp_file!"
)

echo Done! All .md files updated.
pause
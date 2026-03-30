@echo off
setlocal enabledelayedexpansion

for %%f in (*.md) do (
    echo Processing %%f...
    set "tmpfile=%%f.tmp"

    echo ^<div dir="rtl"^> > "!tmpfile!"
    type "%%f" >> "!tmpfile!"
    echo ^</div^> >> "!tmpfile!"

    move /Y "!tmpfile!" "%%f" >nul
)

echo Done. All .md files updated in current folder.
pause

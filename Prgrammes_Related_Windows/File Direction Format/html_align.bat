@echo off
setlocal enabledelayedexpansion

set "css=body {direction: rtl;} pre code {direction: ltr; text-align: left;}"

for %%f in (*.html) do (
    echo Processing %%f
    (
        echo ^<style^>!css!^</style^>
        type "%%f"
    ) > "temp_%%f"
    move /Y "temp_%%f" "%%f" >nul
)

echo Done.
pause

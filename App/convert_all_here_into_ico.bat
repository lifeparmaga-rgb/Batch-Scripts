@echo off
mkdir output

for %%i in (*.png *.jpg *.jpeg) do (
    magick "%%i" -define icon:auto-resize=256,128,64,48,32,16 "output/%%~ni.ico"
)

echo Done!
pause
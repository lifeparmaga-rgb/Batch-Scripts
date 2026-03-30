@echo off
cls
color 0b

set /p RES="Enter Resolution: "
for %%f   in (*.txt) do (       
      yt-dlp -f "bestvideo[height<=%res%]+bestaudio/best" -a %%f
)
explorer .
pause
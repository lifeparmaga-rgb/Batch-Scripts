@REM yt-dlp -f "bestvideo[height<=720]+bestaudio/best" <URL>

set /p url="Enter Url: "
set /p res="Enter Resolution: "

: if "%res%"=="" set res=360


yt-dlp -f "bestvideo[height<=%res%]+bestaudio/best"  %url%


explorer .
@REM yt-dlp -f "bestvideo[height<=720]+bestaudio/best" <URL>

set /p url="Enter Url: "
set /p res="Enter Resolution: "

yt-dlp -f "bestvideo[height<=%res%]+bestaudio/best"  --merge-output-format mp4  %url%


explorer .
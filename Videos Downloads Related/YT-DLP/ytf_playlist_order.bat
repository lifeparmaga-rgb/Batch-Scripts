@REM yt-dlp -f "bestvideo[height<=720]+bestaudio/best" <URL>

set /p file_name="Enter file_name: "
set /p res="Enter Resolution: "


yt-dlp --playlist-reverse -f "bestvideo[height<=%res%]+bestaudio/best" -a %file_name%
explorer .
@echo off


set /p APP_PATH="Enter Your Path(App | Folder | *): "
set /p NAME="Type The Name You Want: "

echo @echo off > %NAME%.bat
echo. > %NAME%.bat
echo start %APP_PATH% >> %NAME%.bat



pause
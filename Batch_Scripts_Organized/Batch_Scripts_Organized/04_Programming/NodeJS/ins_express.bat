@REM . == current path

cd.> file_notes.txt
cd.> file_error.txt

start "create app.bat"
mkdir node_modules

xcopy  "P:\Ref\Express_Refer\For Setup Express Js\"  .  /E /I /H /Y

nodemon app.js
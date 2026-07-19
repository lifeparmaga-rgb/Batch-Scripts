@echo off
echo Starting MongoDB server...

:: Start mongod in a new window and keep it running independently
start "MongoDB Server" cmd /k "mongod --dbpath C:\data\db"

:: Optional: wait a bit for mongod to initialize
timeout /t 5 > nul

echo Launching MongoDB Shell...

:: Start mongosh in a new window
start "MongoDB Shell" cmd /k "mongosh"

echo Both mongod and mongosh are running in separate windows.
pause

@echo off

set /p time= Enter Time To Shutdown
set /a TIME=%time%
shutdown -s -t %TIME%
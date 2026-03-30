@echo off

SET  /p wifi_name="Enter Wifi Name: "
cls
echo =================== 
netsh wlan show profile name="%wifi_name%" key=clear >> findstr "Key Content" >> .\wifi_info.txt && echo =================== && netsh wlan show profile name="%wifi_name%" key=clear >> .\wifi_info.txt
echo -----------------------------
echo -----------------------------

pause 

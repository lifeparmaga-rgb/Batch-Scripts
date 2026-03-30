
cleanmgr /sagerun:1

net stop wuauserv
del /f /s /q C:\Windows\SoftwareDistribution\Download\*
del /f /s /q C:\Windows\Prefetch\*
del /f /s /q C:\Windows\MEMORY.DMP
sfc /scannow
DISM /Online /Cleanup-Image /RestoreHealth
del /f /s /q C:\Windows\Installer\*
vssadmin delete shadows /for=C: /all
chkdsk C: /f
del /f /s /q %temp%\*
del /f /s /q C:\Windows\Temp\*
pause
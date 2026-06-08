@echo off
set /p USER_NOW="Who Is User Now " 
 xcopy "C:\Users\H_R\Documents" "P:\Backup\Documents" /E /H /C /I
 xcopy "C:\Users\H_R\Downloads" "P:\Backup\Downloads" /E /H /C /I
 xcopy "C:\Users\H_R\Pictures" "P:\Backup\Pictures" /E /H /C /I
 xcopy "C:\Users\H_R\Videos" "P:\Backup\Videos" /E /H /C /I
 xcopy "C:\Users\H_R\Music" "P:\Backup\Music" /E /H /C /I
 xcopy "C:\Users\H_R\Desktop" "P:\Backup\Desktop" /E /H /C /I
 echo  procss successfully

 explorer P:\Backup


 xcopy "C:\Users\%USER_NOW%\Documents" "P:\Backup\Documents" /E /H /C /I
 xcopy "C:\Users\%USER_NOW%\Downloads" "P:\Backup\Downloads" /E /H /C /I
 xcopy "C:\Users\%USER_NOW%\Pictures" "P:\Backup\Pictures" /E /H /C /I
 xcopy "C:\Users\%USER_NOW%\Videos" "P:\Backup\Videos" /E /H /C /I
 xcopy "C:\Users\%USER_NOW%\Music" "P:\Backup\Music" /E /H /C /I
 xcopy "C:\Users\%USER_NOW%\Desktop" "P:\Backup\Desktop" /E /H /C /I
 
  echo  procss successfully
  explorer P:\Backup

  @REM NOT WORK
@REM robocopy "C:\Users\H_R\Documents" "D:\Backup\Documents" /E /COPYALL /R:3 /W:5
@REM robocopy "C:\Users\H_R\Downloads" "D:\Backup\Downloads" /E /COPYALL /R:3 /W:5
@REM robocopy "C:\Users\H_R\Pictures" "D:\Backup\Pictures" /E /COPYALL /R:3 /W:5
@REM robocopy "C:\Users\H_R\Music" "D:\Backup\Music" /E /COPYALL /R:3 /W:5
@REM robocopy "C:\Users\H_R\Videos" "D:\Backup\Videos" /E /COPYALL /R:3 /W:5
@REM robocopy "C:\Users\H_R\Desktop" "D:\Backup\Desktop" /E /COPYALL /R:3 /W:5

@REM explorer P:\Backup

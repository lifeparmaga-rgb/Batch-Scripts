@echo off
set /p COMMIT_MSG= Enter Commit Msg: 
git acp -m "%COMMIT_MSG%"
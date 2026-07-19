@echo off
setlocal

:: اسم ملف التخزين
set BRANCH_FILE=branch.txt

:: لو الملف مش موجود → اسأل المستخدم
if not exist %BRANCH_FILE% (
    set /p branch=Enter default branch name: 
    echo %branch% > %BRANCH_FILE%
) else (
    set /p branch=<%BRANCH_FILE%
)

echo Current branch: %branch%
echo.

:: اسأل المستخدم لو عايز يغير
set /p newBranch=Press Enter to use default OR type new branch: 

if not "%newBranch%"=="" (
    set branch=%newBranch%
    echo %branch% > %BRANCH_FILE%
)

:: ====== 🔍 التأكد من وجود تغييرات ======
git status --porcelain > temp_status.txt

for %%i in (temp_status.txt) do set size=%%~zi

if %size%==0 (
    echo No changes to commit ❌
) else (
    :: commit message
    set /p msg=Enter commit message: 

    git add .
    git commit -m "%msg%"
)

del temp_status.txt

:: ====== 🔄 سحب التحديثات من GitHub ======
echo.
echo Checking for remote updates...

git fetch origin %branch%

for /f %%i in ('git rev-list HEAD...origin/%branch% --count') do set diff=%%i

if not "%diff%"=="0" (
    echo Remote changes found. Pulling...
    git pull origin %branch%
) else (
    echo No remote updates ✅
)

:: ====== 🚀 push ======
git push origin %branch%

echo.
echo Done ✅
pause
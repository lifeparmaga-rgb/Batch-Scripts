@echo off
setlocal

REM === Set version and URLs ===
set "version=0.12.6"
set "download_url=https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/%version%/wkhtmltox-%version%-1.msvc2015-win64.exe"
set "installer=wkhtmltox-installer.exe"
set "wkhtmltopdf_path=%~dp0wkhtmltopdf\bin\wkhtmltopdf.exe"

REM === Download wkhtmltopdf if not exists ===
if not exist "%installer%" (
    echo Downloading wkhtmltopdf installer...
    powershell -Command "Invoke-WebRequest -Uri '%download_url%' -OutFile '%installer%'"
)

REM === Silent install to subfolder ===
if not exist "wkhtmltopdf\bin\wkhtmltopdf.exe" (
    echo Installing wkhtmltopdf...
    mkdir wkhtmltopdf
    start /wait "" "%installer%" /S /DIR="%~dp0wkhtmltopdf"
)

REM === Check if wkhtmltopdf is ready ===
if not exist "%wkhtmltopdf_path%" (
    echo Failed to install wkhtmltopdf.
    pause
    exit /b
)

REM === Convert all HTML files to PDF ===
for %%f in (*.html) do (
    echo Converting: %%f
    "%wkhtmltopdf_path%" "%%f" "%%~nf.pdf"
)

echo Done!
pause

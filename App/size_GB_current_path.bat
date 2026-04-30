@echo off

powershell -command "& { Get-ChildItem -Recurse ./' | Measure-Object -Property Length -Sum | ForEach-Object { [math]::Round($_.Sum / 1GB, 2) } }" 
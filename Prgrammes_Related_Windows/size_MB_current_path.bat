@ECHO OFF

powershell -command "& { Get-ChildItem -Recurse './' | Measure-Object -Property Length -Sum | ForEach-Object { [math]::Round($_.Sum / 1MB, 2) } }" 
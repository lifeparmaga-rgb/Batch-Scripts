Clear-Host
Write-Host "====================================="
Write-Host " 1  -> Close all open windows only"
Write-Host " Enter -> Close windows + FULL shutdown"
Write-Host "====================================="
$choice = Read-Host "Choose option"

# اغلاق كل البرامج اللي ليها نافذة في Taskbar
Get-Process |
Where-Object {
    $_.MainWindowHandle -ne 0 -and
    $_.ProcessName -notin @("powershell", "pwsh")
} |
ForEach-Object {
    try {
        Stop-Process -Id $_.Id -Force
    } catch {}
}

# اغلاق File Explorer
taskkill /F /IM explorer.exe > $null 2>&1

# لو المستخدم اختار 1 → خروج فقط
if ($choice -eq "1") {
    Write-Host "Windows closed only. No shutdown."
    exit
}

# غير كده → Shutdown كامل
Write-Host "Shutting down the computer (FULL shutdown)..."
shutdown /s /f /t 0

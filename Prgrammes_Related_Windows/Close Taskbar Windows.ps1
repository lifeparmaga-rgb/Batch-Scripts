# اغلاق كل البرامج الخاصة بالمستخدم (Taskbar Apps)
Get-Process |
Where-Object {
    $_.MainWindowHandle -ne 0 -and
    $_.ProcessName -notin @("explorer", "powershell", "pwsh")
} |
ForEach-Object {
    try {
        Stop-Process -Id $_.Id -Force
    } catch {}
}

# اغلاق File Explorer
taskkill /F /IM explorer.exe

# اعادة تشغيل explorer (اختياري – احذف السطر ده لو مش عايزه)
Start-Process explorer.exe

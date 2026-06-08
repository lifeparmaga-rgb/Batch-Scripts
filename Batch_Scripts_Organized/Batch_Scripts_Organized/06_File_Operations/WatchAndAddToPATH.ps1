# ── بناء قائمة الـ Watchers ───────────────────────────────────
$watchers = [System.Collections.Generic.List[System.IO.FileSystemWatcher]]::new()

function New-Watcher($path) {
    if (-not (Test-Path $path)) { return }
    if (Is-Excluded $path)      { return }

    $w = [System.IO.FileSystemWatcher]::new()
    $w.Path                  = $path
    $w.IncludeSubdirectories = $false
    $w.NotifyFilter          = [System.IO.NotifyFilters]::FileName -bor
                               [System.IO.NotifyFilters]::DirectoryName
    $w.EnableRaisingEvents   = $true

    # ✅ تمرير المتغيرات عبر MessageData
    $messageData = @{
        AllowedExtensions = $AllowedExtensions
        ExcludeFolders    = $ExcludeFolders
        WatcherList       = $watchers
    }

    Register-ObjectEvent -InputObject $w -EventName "Created" `
        -MessageData $messageData -Action {

        $item      = $Event.SourceEventArgs.FullPath
        $data      = $Event.MessageData
        $allowed   = $data.AllowedExtensions
        $excluded  = $data.ExcludeFolders

        # دالة Is-Excluded محلية داخل الـ Action
        $isExcluded = $false
        foreach ($ex in $excluded) {
            if ($item -match "\\$([regex]::Escape($ex))(\\|$)") {
                $isExcluded = $true; break
            }
        }

        $isDir = (Test-Path $item -PathType Container)

        if ($isDir) {
            if (-not $isExcluded) {
                Write-Host "[NEW DIR] مجلد جديد: $item" -ForegroundColor Yellow

                # ✅ إنشاء Watcher للمجلد الجديد مباشرة هنا
                $nw = [System.IO.FileSystemWatcher]::new()
                $nw.Path                  = $item
                $nw.IncludeSubdirectories = $false
                $nw.NotifyFilter          = [System.IO.NotifyFilters]::FileName -bor
                                            [System.IO.NotifyFilters]::DirectoryName
                $nw.EnableRaisingEvents   = $true
                # (يمكن تكرار Register-ObjectEvent هنا لو احتجت)
                $data.WatcherList.Add($nw)
                Write-Host "[WATCHING] $item" -ForegroundColor DarkCyan
            }
        }
        else {
            # فحص الامتداد
            $ext = [System.IO.Path]::GetExtension($item).ToLower()
            $shouldAdd = ($allowed.Count -eq 0) -or ($ext -in $allowed)

            if ($shouldAdd -and -not $isExcluded) {
                $folder  = Split-Path $item -Parent
                $current = [Environment]::GetEnvironmentVariable("Path", "User")
                $list    = $current -split ';' | Where-Object { $_ -ne "" }

                if ($folder -notin $list) {
                    $newPath = ($list + $folder) -join ';'
                    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
                    Write-Host "[ADDED] تمت الإضافة: $folder" -ForegroundColor Green
                } else {
                    Write-Host "[EXISTS] موجود: $folder" -ForegroundColor Cyan
                }
            }
        }
    } | Out-Null

    $watchers.Add($w)
    Write-Host "[WATCHING] $path" -ForegroundColor DarkCyan
}
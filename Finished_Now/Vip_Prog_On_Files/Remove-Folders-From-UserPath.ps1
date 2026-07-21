param(
    [int]$Depth = 99   # تقدر تتحكم في العمق
)

# Get current PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$pathList = $currentPath -split ";" | ForEach-Object { $_.TrimEnd("\") }

# Current folder
$baseDir = (Get-Location).Path

# Get folders (نفس المنطق بتاع سكريبت الإضافة)
$folders = Get-ChildItem -Path $baseDir -Directory -Recurse -Depth $Depth |
           Select-Object -ExpandProperty FullName

# Include base folder
$folders = @($baseDir) + $folders

# Normalize
$folders = $folders | ForEach-Object { $_.TrimEnd("\") }

# فلترة: هات بس اللي في الـ PATH وموجود في القائمة دي (يعني هيتشال)
$foldersToRemove = $folders

# القائمة الجديدة = القديمة ناقص أي مسار موجود في $foldersToRemove
$updatedPathList = $pathList | Where-Object {
    -not ($foldersToRemove -contains $_)
}

$removedFolders = $pathList | Where-Object {
    $foldersToRemove -contains $_
}

if ($removedFolders.Count -gt 0) {
    $updatedPath = ($updatedPathList -join ";")
    [Environment]::SetEnvironmentVariable("PATH", $updatedPath, "User")

    Write-Host "🗑️ Removed folders:" -ForegroundColor Red
    $removedFolders | ForEach-Object { Write-Host " - $_" }
} else {
    Write-Host "⚠️ No matching folders found in PATH." -ForegroundColor Yellow
}

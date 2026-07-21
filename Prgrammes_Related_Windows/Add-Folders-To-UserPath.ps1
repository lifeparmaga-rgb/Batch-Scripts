param(
    [int]$Depth = 99   # تقدر تتحكم في العمق
)

# Get current PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$pathList = $currentPath -split ";" | ForEach-Object { $_.TrimEnd("\") }

# Current folder
$baseDir = (Get-Location).Path

# Get folders
$folders = Get-ChildItem -Path $baseDir -Directory -Recurse -Depth $Depth |
           Select-Object -ExpandProperty FullName

# Include base folder
$folders = @($baseDir) + $folders

# Normalize
$folders = $folders | ForEach-Object { $_.TrimEnd("\") }

# Filter new ones only
$newFolders = $folders | Where-Object {
    -not ($pathList -contains $_)
}

if ($newFolders.Count -gt 0) {
    $updatedPath = ($pathList + $newFolders) -join ";"
    [Environment]::SetEnvironmentVariable("PATH", $updatedPath, "User")

    Write-Host "✅ Added folders:" -ForegroundColor Green
    $newFolders | ForEach-Object { Write-Host " + $_" }
} else {
    Write-Host "⚠️ No new folders found." -ForegroundColor Yellow
}
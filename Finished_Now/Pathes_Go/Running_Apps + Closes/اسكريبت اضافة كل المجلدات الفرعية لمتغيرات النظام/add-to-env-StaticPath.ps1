# ============================================
# Add folders recursively to USER PATH
# with exclude support
# ============================================

# المسار الأساسي
$BasePath = "D:\Batch Scripts"

# المجلدات المستثناة (أي مجلد وما تحته)
$ExcludeFolders = @(
    "node_modules",
    ".git",
    "temp",
    "cache"
)

# الملفات المستثناة (لو موجودة داخل مجلد يتم تجاهل المجلد)
$ExcludeFiles = @(
    "ignore.txt",
    ".exclude"
)

# جلب PATH الحالي للمستخدم
$CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")

# تحويل PATH لمصفوفة
$PathList = $CurrentPath -split ';' | Where-Object { $_ -ne "" }

# دالة تفحص هل المجلد مستثنى
function Is-ExcludedFolder {
    param($FolderPath)

    foreach ($Excluded in $ExcludeFolders) {
        if ($FolderPath -match "\\$([regex]::Escape($Excluded))(\\|$)") {
            return $true
        }
    }

    return $false
}

# جلب كل المجلدات الفرعية
$Folders = Get-ChildItem -Path $BasePath -Directory -Recurse -Force |
Where-Object {

    # استثناء المجلدات
    if (Is-ExcludedFolder $_.FullName) {
        return $false
    }

    # استثناء المجلد لو يحتوي ملف معين
    foreach ($File in $ExcludeFiles) {
        if (Test-Path (Join-Path $_.FullName $File)) {
            return $false
        }
    }

    return $true
}

# إضافة المجلد الأساسي نفسه
$AllPaths = @($BasePath) + ($Folders.FullName)

# إزالة المكرر
$NewPaths = $AllPaths | Where-Object {
    $_ -notin $PathList
}

if ($NewPaths.Count -gt 0) {

    $UpdatedPath = ($PathList + $NewPaths) -join ';'

    [Environment]::SetEnvironmentVariable(
        "Path",
        $UpdatedPath,
        "User"
    )

    Write-Host "تم إضافة المسارات التالية إلى User PATH:`n" -ForegroundColor Green
    $NewPaths | ForEach-Object {
        Write-Host $_
    }
}
else {
    Write-Host "لا توجد مسارات جديدة للإضافة." -ForegroundColor Yellow
}
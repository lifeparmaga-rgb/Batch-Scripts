# ============================================
# Add folders recursively to USER PATH
# with exclude support
# ============================================

# ============================================
# قراءة المسار من المستخدم
# إذا ضغط Enter بدون إدخال شيء
# يستخدم المجلد الحالي
# ============================================

$DefaultPath = (Get-Location).Path

$InputPath = Read-Host "أدخل المسار الأساسي (Enter = $DefaultPath)"

if ([string]::IsNullOrWhiteSpace($InputPath)) {
    $BasePath = $DefaultPath
}
else {
    # إزالة علامات الاقتباس إن وجدت
    $BasePath = $InputPath.Trim('"')
}

# التأكد من وجود المجلد
if (!(Test-Path -LiteralPath $BasePath -PathType Container)) {
    Write-Host ""
    Write-Host "❌ المسار غير موجود:" -ForegroundColor Red
    Write-Host $BasePath -ForegroundColor Yellow
    exit
}

# تحويله إلى المسار الكامل
$BasePath = (Resolve-Path -LiteralPath $BasePath).Path

# ============================================
# المجلدات المستثناة (أي مجلد وما تحته)
# ============================================

$ExcludeFolders = @(
    "node_modules",
    ".git",
    "temp",
    "cache"
)

# ============================================
# الملفات المستثناة
# إذا وجد أحدها داخل مجلد يتم تجاهل المجلد
# ============================================

$ExcludeFiles = @(
    "ignore.txt",
    ".exclude"
)

# ============================================
# جلب PATH الحالي للمستخدم
# ============================================

$CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")

# تحويل PATH إلى مصفوفة
$PathList = $CurrentPath -split ';' | Where-Object { $_ -ne "" }

# ============================================
# دالة تتحقق هل المجلد مستثنى
# ============================================

function Is-ExcludedFolder {
    param($FolderPath)

    foreach ($Excluded in $ExcludeFolders) {
        if ($FolderPath -match "\\$([regex]::Escape($Excluded))(\\|$)") {
            return $true
        }
    }

    return $false
}

# ============================================
# جلب جميع المجلدات الفرعية
# ============================================

$Folders = Get-ChildItem -LiteralPath $BasePath -Directory -Recurse -Force |
Where-Object {

    # استثناء المجلدات
    if (Is-ExcludedFolder $_.FullName) {
        return $false
    }

    # استثناء المجلد إذا احتوى على ملف معين
    foreach ($File in $ExcludeFiles) {
        if (Test-Path -LiteralPath (Join-Path $_.FullName $File)) {
            return $false
        }
    }

    return $true
}

# ============================================
# إضافة المجلد الأساسي نفسه
# ============================================

$AllPaths = @($BasePath) + ($Folders.FullName)

# إزالة المسارات المكررة
$NewPaths = $AllPaths | Where-Object {
    $_ -notin $PathList
}

# ============================================
# تحديث User PATH
# ============================================

if ($NewPaths.Count -gt 0) {

    $UpdatedPath = ($PathList + $NewPaths) -join ';'

    [Environment]::SetEnvironmentVariable(
        "Path",
        $UpdatedPath,
        "User"
    )

    Write-Host ""
    Write-Host "✅ تمت إضافة المسارات التالية إلى User PATH:" -ForegroundColor Green
    Write-Host ""

    $NewPaths | ForEach-Object {
        Write-Host $_
    }
}
else {

    Write-Host ""
    Write-Host "⚠️ لا توجد مسارات جديدة للإضافة." -ForegroundColor Yellow
}
# امتدادات الفيديو
$videoExtensions = @("*.mp4","*.mkv","*.avi","*.mov","*.wmv","*.flv","*.webm","*.mpeg","*.mpg")

# جمع كل ملفات الفيديو
$files = foreach ($ext in $videoExtensions) {
    Get-ChildItem -Filter $ext -File
}

# ترتيب حسب تاريخ الإنشاء
$files = $files | Sort-Object CreationTime

# عدد الملفات
$count = $files.Count

# تحديد عدد الخانات
if ($count -ge 100) {
    $pad = 3
} else {
    $pad = 2
}

$index = 0

foreach ($file in $files) {

    # تخطي الملفات اللي فيها رقم بالفعل (مثلاً 01 - filename)
    if ($file.Name -match "^\d{2,3}\s*[-_]") {
        Write-Host "Skipped: $($file.Name)"
        continue
    }

    $number = $index.ToString("D$pad")
    $newName = "$number - $($file.Name)"

    Rename-Item -LiteralPath $file.FullName -NewName $newName

    Write-Host "$($file.Name)  -->  $newName"

    $index++
}

Write-Host "`nDone!"
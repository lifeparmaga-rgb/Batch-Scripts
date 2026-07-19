Get-ChildItem -File | ForEach-Object {
    $name = $_.BaseName
    $ext  = $_.Extension

    # حذف أي جزء بين []
    $newName = $name -replace "\s*\[.*?\]", ""

    # إزالة المسافات الزائدة
    $newName = $newName.Trim()

    # إعادة التسمية لو الاسم مش فاضي واتغير
    if ($newName -ne "" -and ($newName + $ext) -ne $_.Name) {
        Write-Host "Renaming: $($_.Name) -> $newName$ext"
        Rename-Item -LiteralPath $_.FullName -NewName ($newName + $ext)
    }
}
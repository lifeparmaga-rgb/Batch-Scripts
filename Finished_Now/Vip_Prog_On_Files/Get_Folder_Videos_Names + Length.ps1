# الامتدادات اللي هنعتبرها فيديو
$videoExtensions = @("*.mp4","*.mkv","*.avi","*.mov","*.wmv","*.flv","*.webm","*.mpeg","*.mpg")

# إنشاء ملف الخرج
$outputFile = "video_durations.txt"
if (Test-Path $outputFile) {
    Remove-Item $outputFile
}

# تحميل COM Object لقراءة الميتاداتا
$shell = New-Object -ComObject Shell.Application
$folder = $shell.Namespace((Get-Location).Path)

foreach ($ext in $videoExtensions) {
    Get-ChildItem -Filter $ext | ForEach-Object {

        $file = $_
        $folderItem = $folder.ParseName($file.Name)

        # عمود مدة الفيديو (غالبًا index = 27)
        $duration = $folder.GetDetailsOf($folderItem, 27)

        # لو فشل نحط Unknown
        if (-not $duration) {
            $duration = "Unknown"
        }

        $line = "$($file.Name)  -->  $duration"
        $line | Out-File -Append -Encoding UTF8 $outputFile

        Write-Host $line
    }
}

Write-Host "`nDone! Saved to $outputFile"
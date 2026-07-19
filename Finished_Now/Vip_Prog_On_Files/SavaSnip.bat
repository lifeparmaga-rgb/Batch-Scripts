@echo off
chcp 65001 >nul
title SaveSnip - جاري المراقبة...

:: ============================================
::  SaveSnip.bat — حفظ أي Snip تلقائيًا
:: ============================================

:: ── مكان حفظ الصور ──
set "SaveFolder=%USERPROFILE%\Pictures\Snips"

:: ── إنشاء المجلد لو مش موجود ──
if not exist "%SaveFolder%" mkdir "%SaveFolder%"

cls

echo.
echo  ╔══════════════════════════════════════════════╗
echo  ║              SaveSnip مفعّل                 ║
echo  ║                                              ║
echo  ║   اضغط Win+Shift+S وخد Screenshot           ║
echo  ║                                              ║
echo  ║   الصور هتتحفظ تلقائيًا هنا:                ║
echo  ║   %SaveFolder%
echo  ║                                              ║
echo  ║   اضغط Ctrl+C للإيقاف                       ║
echo  ╚══════════════════════════════════════════════╝
echo.

:: ============================================
:: تشغيل PowerShell لمراقبة الـ Clipboard
:: ============================================

powershell -NoProfile -ExecutionPolicy Bypass -STA -Command ^
"$saveFolder = '%SaveFolder%'; ^
Add-Type -AssemblyName System.Windows.Forms; ^
Add-Type -AssemblyName System.Drawing; ^
Write-Host ' [جاهز] في انتظار لقطة شاشة...' -ForegroundColor Cyan; ^
$lastHash = ''; ^
while ($true) { ^
    Start-Sleep -Milliseconds 700; ^
    try { ^
        if ([System.Windows.Forms.Clipboard]::ContainsImage()) { ^
            $img = [System.Windows.Forms.Clipboard]::GetImage(); ^
            if ($img -ne $null) { ^
                $ms = New-Object System.IO.MemoryStream; ^
                $img.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png); ^
                $hash = [Convert]::ToBase64String($ms.ToArray()); ^
                if ($hash -ne $lastHash) { ^
                    $lastHash = $hash; ^
                    $timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'; ^
                    $fileName = Join-Path $saveFolder ('Snip_' + $timestamp + '.png'); ^
                    $img.Save($fileName, [System.Drawing.Imaging.ImageFormat]::Png); ^
                    Write-Host (' [تم الحفظ] ' + $fileName) -ForegroundColor Green; ^
                } ^
                $ms.Dispose(); ^
                $img.Dispose(); ^
            } ^
        } ^
    } catch { ^
        Write-Host (' [خطأ] ' + $_.Exception.Message) -ForegroundColor Red; ^
    } ^
}"

pause
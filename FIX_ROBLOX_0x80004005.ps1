#Requires -RunAsAdministrator
$ErrorActionPreference = "SilentlyContinue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " FIX ROBLOX - ERROR 0x80004005" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

function Step($n,$text) {
    Write-Host "`n[$n] $text" -ForegroundColor Yellow
}

Step 1 "Menutup Roblox, Xbox dan Microsoft Store..."
$processes = @(
    "RobloxPlayerBeta","Roblox","Windows10Universal",
    "XboxPcApp","WinStore.App"
)
foreach ($p in $processes) {
    Stop-Process -Name $p -Force
}

Step 2 "Membersihkan cache Roblox..."
$robloxPath = Join-Path $env:LOCALAPPDATA "Roblox"
if (Test-Path $robloxPath) {
    Remove-Item $robloxPath -Recurse -Force
}

Step 3 "Reset Microsoft Store..."
Start-Process "wsreset.exe" -Wait
Start-Sleep -Seconds 3
Stop-Process -Name "WinStore.App" -Force

Step 4 "Re-register Microsoft Store..."
$store = Get-AppxPackage -AllUsers Microsoft.WindowsStore
if ($store) {
    foreach ($pkg in $store) {
        $manifest = Join-Path $pkg.InstallLocation "AppXManifest.xml"
        if (Test-Path $manifest) {
            Add-AppxPackage -DisableDevelopmentMode -Register $manifest
        }
    }
}

Step 5 "Re-register Xbox Identity Provider..."
$xboxId = Get-AppxPackage -AllUsers Microsoft.XboxIdentityProvider
if ($xboxId) {
    foreach ($pkg in $xboxId) {
        $manifest = Join-Path $pkg.InstallLocation "AppXManifest.xml"
        if (Test-Path $manifest) {
            Add-AppxPackage -DisableDevelopmentMode -Register $manifest
        }
    }
}

Step 6 "Memperbaiki layanan Xbox..."
$services = @("XblAuthManager","XboxNetApiSvc","XblGameSave")
foreach ($svc in $services) {
    Set-Service $svc -StartupType Automatic
    Start-Service $svc
}

Step 7 "Memeriksa Gaming Services..."
Get-AppxPackage -AllUsers Microsoft.GamingServices |
    Select-Object Name, PackageFullName, InstallLocation |
    Format-Table -AutoSize

Step 8 "Memperbaiki Windows dengan DISM..."
DISM.exe /Online /Cleanup-Image /RestoreHealth

Step 9 "Memeriksa file sistem dengan SFC..."
sfc.exe /scannow

Step 10 "Membersihkan component store..."
DISM.exe /Online /Cleanup-Image /StartComponentCleanup

Step 11 "Mengecek paket Roblox..."
$roblox = Get-AppxPackage -AllUsers *Roblox*
if ($roblox) {
    $roblox | Select-Object Name, PackageFullName, InstallLocation |
        Format-List
} else {
    Write-Host "Paket Roblox Microsoft Store tidak ditemukan." -ForegroundColor DarkYellow
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host " PERBAIKAN SELESAI" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Windows akan restart dalam 15 detik." -ForegroundColor Cyan
Write-Host "Tekan Ctrl+C jika ingin membatalkan restart." -ForegroundColor DarkYellow

Start-Sleep -Seconds 15
Restart-Computer

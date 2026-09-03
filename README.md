# 🔧 Perbaikan Roblox Error 0x80004005 — Windows 10

Panduan step-by-step untuk memperbaiki Roblox yang gagal sign-in dengan:

> There was a problem signing you in. Try again in a bit.  
> Error code: `0x80004005`

> **Catatan:** Jalankan langkah secara berurutan. Setelah langkah penting selesai, coba Roblox sebelum melanjutkan. Jangan menghapus seluruh aplikasi AppX Windows.

---

## STEP 0 — Tutup Roblox, Xbox, dan Microsoft Store

Buka **CMD sebagai Administrator**.

Jalankan:

```cmd
taskkill /F /IM RobloxPlayerBeta.exe 2>nul
taskkill /F /IM Windows10Universal.exe 2>nul
taskkill /F /IM Roblox.exe 2>nul
taskkill /F /IM XboxPcApp.exe 2>nul
taskkill /F /IM WinStore.App.exe 2>nul
```

Pesan `process not found` boleh diabaikan.

---

## STEP 1 — Reset Microsoft Store

Di CMD Administrator:

```cmd
wsreset.exe
```

Tunggu sampai proses selesai dan Microsoft Store terbuka.

Setelah itu **restart PC** dan coba Roblox.

Jika masih `0x80004005`, lanjut.

---

## STEP 2 — Bersihkan Cache Roblox

Tekan:

**Win + R**

Masukkan:

```text
%localappdata%
```

Cari folder:

```text
Roblox
```

Hapus folder tersebut.

Kemudian **restart PC**.

> Jika folder Roblox tidak ada, lanjut ke langkah berikutnya.

---

## STEP 3 — Cek Paket Roblox

Buka **PowerShell sebagai Administrator**.

Jalankan:

```powershell
Get-AppxPackage -AllUsers *Roblox* | Select Name,PackageFullName,InstallLocation
```

Simpan hasilnya.

Jika ada hasil, jangan hapus paketnya dulu. Lanjutkan diagnosis.

---

## STEP 4 — Repair Gaming Services

Buka **PowerShell Administrator**.

Jalankan:

```powershell
Get-AppxPackage Microsoft.GamingServices -AllUsers | Remove-AppxPackage -AllUsers
```

Kemudian:

```powershell
start ms-windows-store://pdp/?productid=9MWPM2CQNLHN
```

Microsoft Store akan membuka halaman **Gaming Services**.

Klik:

**Get / Install**

Setelah selesai, restart:

```powershell
Restart-Computer
```

---

## STEP 5 — Re-register Xbox Identity Provider

Buka **PowerShell Administrator**:

```powershell
Get-AppxPackage -AllUsers Microsoft.XboxIdentityProvider | ForEach-Object {
    Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"
}
```

Jika paket ditemukan dan proses selesai, lanjut.

Cek juga Xbox App:

```powershell
Get-AppxPackage -AllUsers Microsoft.XboxApp | ForEach-Object {
    Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"
}
```

Jika ada pesan merah, jangan langsung menghapus paket. Catat error-nya.

---

## STEP 6 — Pastikan Layanan Xbox Aktif

Di PowerShell Administrator:

```powershell
Get-Service XboxNetApiSvc,XblAuthManager,XblGameSave,XboxGipSvc,GamingServices,GamingServicesNet
```

Kemudian:

```powershell
Set-Service XblAuthManager -StartupType Automatic
Set-Service XboxNetApiSvc -StartupType Automatic
Set-Service XblGameSave -StartupType Automatic
```

Start layanan:

```powershell
Start-Service XblAuthManager
Start-Service XboxNetApiSvc
Start-Service XblGameSave
```

Jika Gaming Services tidak bisa di-start manual, jangan dipaksakan.

---

## STEP 7 — Perbaiki File Sistem Windows

Buka **CMD sebagai Administrator**.

### 7.1 DISM

```cmd
DISM /Online /Cleanup-Image /RestoreHealth
```

Tunggu sampai **100%**.

### 7.2 SFC

Setelah DISM selesai:

```cmd
sfc /scannow
```

Tunggu sampai selesai.

### 7.3 Component Cleanup

```cmd
DISM /Online /Cleanup-Image /StartComponentCleanup
```

### 7.4 Restart

```cmd
shutdown /r /t 0
```

---

## STEP 8 — Re-register Microsoft Store

Setelah Windows menyala kembali, pastikan **Microsoft Store benar-benar tertutup**.

Buka **PowerShell Administrator**:

```powershell
Get-AppxPackage -AllUsers Microsoft.WindowsStore | ForEach-Object {
    Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"
}
```

Kemudian:

```powershell
Restart-Computer
```

> **Penting:** Jangan menjalankan re-register saat Microsoft Store sedang terbuka. Jika muncul `0x80073D02`, biasanya ada resource aplikasi yang sedang digunakan.

---

# STEP 9 — Cek Gaming Services dan Xbox Identity

PowerShell Administrator:

```powershell
Get-AppxPackage -AllUsers Microsoft.GamingServices | Select Name,PackageFullName,InstallLocation
```

Lalu:

```powershell
Get-AppxPackage -AllUsers Microsoft.XboxIdentityProvider | Select Name,PackageFullName,InstallLocation
```

Dan:

```powershell
Get-AppxPackage -AllUsers *Roblox* | Select Name,PackageFullName,InstallLocation
```

Simpan/copy hasil ketiganya jika Roblox masih error.

---

# STEP 10 — Jangan Hapus Semua AppX

**JANGAN menjalankan perintah seperti:**

```powershell
Get-AppxPackage -AllUsers | Remove-AppxPackage -AllUsers
```

Perintah tersebut terlalu agresif dan dapat mengganggu aplikasi Windows lain seperti:

- Microsoft Store
- Xbox
- Calculator
- Photos
- aplikasi bawaan Windows lainnya

Kita hanya memperbaiki paket yang berhubungan dengan Roblox/Xbox/Gaming Services.

---

# STEP 11 — Jika Roblox Masih Error

Jika setelah semua langkah di atas Roblox masih menampilkan:

```text
Error code: (0x80004005)
```

Jalankan 3 perintah berikut dan **copy seluruh hasilnya**:

```powershell
Get-AppxPackage -AllUsers *Roblox* | Select Name,PackageFullName,InstallLocation
```

```powershell
Get-AppxPackage -AllUsers Microsoft.GamingServices | Select Name,PackageFullName,InstallLocation
```

```powershell
Get-AppxPackage -AllUsers Microsoft.XboxIdentityProvider | Select Name,PackageFullName,InstallLocation
```

Hasil tersebut akan membantu menentukan apakah masalah berada di:

1. Roblox Microsoft Store
2. Gaming Services
3. Xbox Identity Provider
4. Microsoft Store/AppX
5. File sistem Windows

---

# 🚨 Catatan Khusus Untuk Error 0x80073D02

Jika saat menjalankan:

```powershell
Add-AppxPackage -DisableDevelopmentMode -Register ...
```

muncul:

```text
0x80073D02
The package could not be installed because resources it modifies are currently in use.
```

Artinya paket sedang digunakan oleh aplikasi/proses lain.

Lakukan:

```cmd
taskkill /F /IM WinStore.App.exe 2>nul
taskkill /F /IM XboxPcApp.exe 2>nul
taskkill /F /IM RobloxPlayerBeta.exe 2>nul
```

Kemudian ulangi perintah PowerShell.

Jika masih muncul, **restart Windows terlebih dahulu**, jangan menghapus paket secara paksa.

---

# ✅ Urutan Singkat

```text
1. Tutup Roblox/Xbox/Store
        ↓
2. wsreset.exe
        ↓
3. Hapus %localappdata%\Roblox
        ↓
4. Restart
        ↓
5. Repair/Reinstall Gaming Services
        ↓
6. Re-register Xbox Identity
        ↓
7. Cek layanan Xbox
        ↓
8. DISM /RestoreHealth
        ↓
9. sfc /scannow
        ↓
10. StartComponentCleanup
        ↓
11. Re-register Microsoft Store
        ↓
12. Restart
        ↓
13. Tes Roblox
```

---

# 🟢 Jika Sudah Berhasil

Setelah Roblox bisa dibuka:

- Jangan melakukan reset AppX lagi.
- Jangan menghapus Gaming Services.
- Jangan menjalankan script debloat yang menghapus aplikasi Windows secara massal.
- Jika tujuan akhirnya adalah menjalankan **2 akun Roblox dalam 1 PC**, lakukan konfigurasi multi-account setelah Roblox normal terlebih dahulu.

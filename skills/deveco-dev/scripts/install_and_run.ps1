param(
    [string]$ProjectDir = "C:\Users\hci\DevEcoStudioProjects\MyApplication",
    [string]$BundleName = "com.example.myapplication"
)

$HDC = "C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe"
$HAP = Join-Path $ProjectDir "entry\build\default\outputs\default\entry-default-signed.hap"

# Check device
Write-Host "=== Checking devices ==="
& $HDC list targets

# Install
Write-Host "`n=== Installing HAP ==="
& $HDC app install -p $HAP

# Launch
Write-Host "`n=== Launching app ==="
& $HDC shell aa start -a EntryAbility -b $BundleName

# Screenshot
Write-Host "`n=== Taking screenshot ==="
$screenshotPath = "C:\Users\hci\.openclaw\workspace\screenshot_verify.png"
Add-Type -AssemblyName System.Windows.Forms
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bmp = New-Object System.Drawing.Bitmap($screen.Width, $screen.Height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($screen.Location, [System.Drawing.Point]::Empty, $bmp.Size)
$bmp.Save($screenshotPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
Write-Host "Screenshot saved: $screenshotPath"

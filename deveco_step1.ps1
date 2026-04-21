Add-Type -AssemblyName System.Windows.Forms
$wshell = New-Object -ComObject WScript.Shell

# Find DevEco Studio window
$devecoProcess = Get-Process | Where-Object { $_.MainWindowTitle -like '*DevEco*' -and $_.MainWindowTitle -ne '' } | Select-Object -First 1
if ($devecoProcess) {
    Write-Host "Found DevEco: $($devecoProcess.MainWindowTitle) (PID: $($devecoProcess.Id))"
    [void]$wshell.AppActivate($devecoProcess.Id)
} else {
    Write-Host "No DevEco window found!"
    exit 1
}

Start-Sleep -Seconds 2

# Step 1: Close the "Run entry on device" dialog with Escape
[System.Windows.Forms.SendKeys]::SendWait('{ESC}')
Start-Sleep -Seconds 1

# Step 2: Open Find Action with Ctrl+Shift+A
[System.Windows.Forms.SendKeys]::SendWait('^+a')
Start-Sleep -Seconds 2

# Step 3: Type "Device Manager"
[System.Windows.Forms.SendKeys]::SendWait('Device Manager')
Start-Sleep -Seconds 2

# Step 4: Press Enter to open Device Manager
[System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
Start-Sleep -Seconds 3

# Step 5: Take screenshot to see what we got
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bitmap = New-Object System.Drawing.Bitmap($screen.Width, $screen.Height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen($screen.Location, [System.Drawing.Point]::Empty, $bitmap.Size)
$bitmap.Save("C:\Users\hci\.openclaw\workspace\screenshot_step1.png", [System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose()
$bitmap.Dispose()

Write-Host "Step 1 complete - opened Device Manager"

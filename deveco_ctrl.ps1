Add-Type -AssemblyName System.Windows.Forms
$wshell = New-Object -ComObject WScript.Shell

# Find DevEco Studio window
$devecoProcess = Get-Process | Where-Object { $_.MainWindowTitle -like '*DevEco*' -and $_.MainWindowTitle -ne '' } | Select-Object -First 1
if ($devecoProcess) {
    Write-Host "Found: $($devecoProcess.MainWindowTitle) PID:$($devecoProcess.Id)"
    [void]$wshell.AppActivate($devecoProcess.Id)
} else {
    Write-Host "No DevEco window found"
    exit 1
}

Start-Sleep -Seconds 2

# Step 1: Close the "Run on device" dialog (Escape)
[System.Windows.Forms.SendKeys]::SendWait('{ESC}')
Start-Sleep -Seconds 1

# Step 2: Open Device Manager via Ctrl+Shift+A -> search
[System.Windows.Forms.SendKeys]::SendWait('^+a')
Start-Sleep -Seconds 2

# Type "Device Manager"
[System.Windows.Forms.SendKeys]::SendWait('Device Manager')
Start-Sleep -Seconds 2

# Press Enter
[System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
Start-Sleep -Seconds 3

# Step 3: Take screenshot to check result
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bmp = New-Object System.Drawing.Bitmap($screen.Width, $screen.Height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($screen.Location, [System.Drawing.Point]::Empty, $bmp.Size)
$bmp.Save("C:\Users\hci\.openclaw\workspace\screenshot2.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()

Write-Host "Done - screenshot saved as screenshot2.png"

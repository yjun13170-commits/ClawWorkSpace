Add-Type -AssemblyName System.Windows.Forms

$wshell = New-Object -ComObject WScript.Shell

# Find DevEco Studio window
$deveco = Get-Process | Where-Object { $_.MainWindowTitle -like '*DevEco*' -and $_.MainWindowTitle -ne '' } | Select-Object -First 1
if ($deveco) {
    Write-Host "Found DevEco: $($deveco.MainWindowTitle)"
    [void]$wshell.AppActivate($deveco.Id)
} else {
    Write-Host "No DevEco window found"
    exit 1
}

Start-Sleep -Seconds 2

# Close the "Run entry on device" dialog by pressing Escape
[System.Windows.Forms.SendKeys]::SendWait('{ESC}')
Start-Sleep -Seconds 1

# Open Device Manager via Ctrl+Shift+A (Find Action)
[System.Windows.Forms.SendKeys]::SendWait('^+a')
Start-Sleep -Seconds 2

# Search for Device Manager
[System.Windows.Forms.SendKeys]::SendWait('Device Manager')
Start-Sleep -Seconds 2

# Press Enter
[System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
Start-Sleep -Seconds 3

Write-Host "Opened Device Manager"

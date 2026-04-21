Add-Type -AssemblyName System.Windows.Forms
$wshell = New-Object -ComObject WScript.Shell

# Find DevEco Studio window
$devecoProcess = Get-Process | Where-Object { $_.MainWindowTitle -like '*DevEco*' -and $_.MainWindowTitle -ne '' } | Select-Object -First 1
if ($devecoProcess) {
    Write-Host "Found DevEco Studio: $($devecoProcess.MainWindowTitle) (PID: $($devecoProcess.Id))"
    [void]$wshell.AppActivate($devecoProcess.Id)
} else {
    Write-Host "No DevEco window found"
    exit 1
}

Start-Sleep -Seconds 2

# Ctrl+Shift+A to open Find Action
[System.Windows.Forms.SendKeys]::SendWait('^+a')
Start-Sleep -Seconds 2

# Type "Device Manager"
[System.Windows.Forms.SendKeys]::SendWait('Device Manager')
Start-Sleep -Seconds 2

# Press Enter
[System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
Start-Sleep -Seconds 3

Write-Host "Done - attempted to open Device Manager"

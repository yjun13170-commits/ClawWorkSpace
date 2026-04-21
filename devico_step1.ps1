Add-Type -AssemblyName System.Windows.Forms

$wshell = New-Object -ComObject WScript.Shell

# Activate DevEco Studio
$result = $wshell.AppActivate('DevEco')
Write-Host "DevEco window found: $result"

Start-Sleep -Seconds 2

# Use keyboard shortcut: Alt + T to open Tools menu, then find Device Manager
# Actually, in DevEco Studio, Device Manager is accessible via Tools -> Device Manager
# Or via the toolbar button

# Let's try Ctrl+Shift+A to open "Find Action" search, then search for Device Manager
[System.Windows.Forms.SendKeys]::SendWait('^(+a)')
Start-Sleep -Seconds 2

# Type "Device Manager"
[System.Windows.Forms.SendKeys]::SendWait('Device Manager')
Start-Sleep -Seconds 2

# Press Enter to open Device Manager
[System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
Start-Sleep -Seconds 3

Write-Host "Step 1 complete - opened Device Manager search"

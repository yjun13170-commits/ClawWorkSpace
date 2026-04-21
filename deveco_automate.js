const { execSync } = require('child_process');

// Use PowerShell with WScript.Shell to send keystrokes to DevEco Studio
const ps = `
Add-Type -AssemblyName System.Windows.Forms
$wshell = New-Object -ComObject WScript.Shell
Start-Sleep -Seconds 2

# Activate DevEco Studio window
[void]$wshell.AppActivate('DevEco')
Start-Sleep -Seconds 1

# Alt+T to open Tools menu, then navigate to Device Manager
[System.Windows.Forms.SendKeys]::SendWait('%(t)')
Start-Sleep -Seconds 2

# Type 'Device Manager' to search in menu
[System.Windows.Forms.SendKeys]::SendWait('Device Manager')
Start-Sleep -Seconds 1

# Enter to select
[System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
Start-Sleep -Seconds 3

echo "Step 1 done - tried to open Device Manager"
`;

execSync(`powershell -Command "${ps}"`, { stdio: 'inherit', timeout: 30000 });

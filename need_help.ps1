[CmdletBinding()]
param(
    [string]$Message = "Help needed!",
    [string]$TaskId = "default"
)

$workspaceDir = "C:\Users\hci\.openclaw\workspace"
$flagDir = Join-Path $workspaceDir "task_flags"
if (!(Test-Path $flagDir)) { New-Item -ItemType Directory -Path $flagDir | Out-Null }
$stopFile = Join-Path $flagDir "STOP.flag"
$flagFile = Join-Path $flagDir "$TaskId.flag"
if (Test-Path $stopFile) { Remove-Item $stopFile -Force }

# Step 1: Three-tone beep pattern (Do-Mi-Sol)
[System.Console]::Beep(523, 200)
Start-Sleep -Milliseconds 80
[System.Console]::Beep(659, 200)
Start-Sleep -Milliseconds 80
[System.Console]::Beep(784, 400)

# Step 2: Desktop notification file
$desktopPath = [Environment]::GetFolderPath("Desktop")
$desktopFile = Join-Path $desktopPath "ji_ge_need_help.txt"
$deskContent = "============================================`n" +
    "Ji Ge needs your help!`n" +
    "============================================`n`n" +
    "$Message`n`n" +
    "Please click OK in the dialog.`n" +
    "============================================"
Set-Content -Path $desktopFile -Value $deskContent -Encoding UTF8 -Force

# Step 3: Write dialog script and launch
$dialogScriptPath = Join-Path $flagDir "$TaskId-dialog.ps1"

$dialogCode = @"
`$flagDir = "C:\Users\hci\.openclaw\workspace\task_flags"
`$stopFile = Join-Path `$flagDir "STOP.flag"
`$desktopFile = Join-Path ([Environment]::GetFolderPath("Desktop")) "ji_ge_need_help.txt"
`$taskFlagFile = Join-Path `$flagDir "$TaskId.flag"

Add-Type -AssemblyName System.Windows.Forms

`$result = [System.Windows.Forms.MessageBox]::Show(
    "Message: $Message",
    "Ji Ge needs your help!",
    [System.Windows.Forms.MessageBoxButtons]::OKCancel,
    [System.Windows.Forms.MessageBoxIcon]::Warning,
    [System.Windows.Forms.MessageBoxDefaultButton]::Button1
)

if (Test-Path `$desktopFile) { Remove-Item `$desktopFile -Force }

if (`$result -eq [System.Windows.Forms.DialogResult]::OK) {
    Set-Content -Path `$stopFile -Value "true" -Force
    Set-Content -Path `$taskFlagFile -Value "user_will_handle" -Force
} else {
    Set-Content -Path `$taskFlagFile -Value "agent_continue" -Force
}
"@

[IO.File]::WriteAllText($dialogScriptPath, $dialogCode, [System.Text.Encoding]::UTF8)

# Launch dialog: window closes after dialog is dismissed (no -NoExit)
$psExe = (Get-Command powershell).Source
Start-Process -FilePath $psExe -ArgumentList "-ExecutionPolicy Bypass -File `"$dialogScriptPath`"" -WindowStyle Normal

Write-Host "NOTIFICATION_LAUNCHED"

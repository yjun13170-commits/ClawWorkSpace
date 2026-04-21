$flagDir = "C:\Users\hci\.openclaw\workspace\task_flags"
$stopFile = Join-Path $flagDir "STOP.flag"
$desktopFile = Join-Path ([Environment]::GetFolderPath("Desktop")) "ji_ge_need_help.txt"
$taskFlagFile = Join-Path $flagDir "default.flag"

Add-Type -AssemblyName System.Windows.Forms

$result = [System.Windows.Forms.MessageBox]::Show(
    "Message: 鸡哥紧急求助：GitHub同步任务死循环17分钟，20+次重复无进展。需要手动处理GitHub同步和文件打包。",
    "Ji Ge needs your help!",
    [System.Windows.Forms.MessageBoxButtons]::OKCancel,
    [System.Windows.Forms.MessageBoxIcon]::Warning,
    [System.Windows.Forms.MessageBoxDefaultButton]::Button1
)

if (Test-Path $desktopFile) { Remove-Item $desktopFile -Force }

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    Set-Content -Path $stopFile -Value "true" -Force
    Set-Content -Path $taskFlagFile -Value "user_will_handle" -Force
} else {
    Set-Content -Path $taskFlagFile -Value "agent_continue" -Force
}
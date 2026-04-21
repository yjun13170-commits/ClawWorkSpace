Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;
public class WinInfo {
    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
}
[StructLayout(LayoutKind.Sequential)]
public struct RECT {
    public int Left, Top, Right, Bottom;
}
"@

$processes = Get-Process | Where-Object { $_.MainWindowTitle -ne '' -and $_.MainWindowTitle -match 'Emulator|harmony|OS|MyApplication' }
foreach ($p in $processes) {
    $rect = New-Object RECT
    $title = New-Object System.Text.StringBuilder(256)
    [WinInfo]::GetWindowRect($p.MainWindowHandle, [ref]$rect) | Out-Null
    [WinInfo]::GetWindowText($p.MainWindowHandle, $title, 256) | Out-Null
    Write-Host "PID: $($p.Id) Title: $title Pos: $($rect.Left),$($rect.Top)-$($rect.Right),$($rect.Bottom) Size: $($rect.Right-$rect.Left)x$($rect.Bottom-$rect.Top)"
}

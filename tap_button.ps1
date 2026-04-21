Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class MouseClicker {
    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int X, int Y);
    [DllImport("user32.dll")]
    public static extern void mouse_event(uint dwFlags, int dx, int dy, int cButtons, int dwExtraInfo);
    public const uint MOUSEEVENTF_LEFTDOWN = 0x02;
    public const uint MOUSEEVENTF_LEFTUP = 0x04;
}
"@

# Get emulator window position
$emulator = Get-Process | Where-Object { $_.MainWindowTitle -like '*Emulator*' -or $_.MainWindowTitle -like '*harmony*' -or $_.MainWindowTitle -like '*OS*' } | Select-Object -First 1

if ($emulator -and $emulator.MainWindowTitle -ne '') {
    Write-Host "Found window: $($emulator.MainWindowTitle)"
    [void]$emulator.WaitForInputIdle(3000)
    $handle = $emulator.MainWindowHandle

    # Get window rect
    $rect = New-Object System.Drawing.Rectangle
    $sig = @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
}
[StructLayout(LayoutKind.Sequential)]
public struct RECT {
    public int Left, Top, Right, Bottom;
}
"@
    Add-Type -TypeDefinition $sig -Language CSharp
    $rectObj = New-Object RECT
    [Win32]::GetWindowRect($handle, [ref]$rectObj) | Out-Null

    Write-Host "Window position: $($rectObj.Left), $($rectObj.Top), $($rectObj.Right), $($rectObj.Bottom)"

    # Calculate click position - roughly center of the screen (where the button should be)
    $cx = $rectObj.Left + (($rectObj.Right - $rectObj.Left) / 2)
    $cy = $rectObj.Top + (($rectObj.Bottom - $rectObj.Top) / 2) + 100

    Write-Host "Clicking at: $cx, $cy"
    [MouseClicker]::SetCursorPos($cx, $cy)
    Start-Sleep -Milliseconds 200
    [MouseClicker]::mouse_event([MouseClicker]::MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
    [MouseClicker]::mouse_event([MouseClicker]::MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)

    Write-Host "Click sent"
} else {
    Write-Host "No emulator window found"
}

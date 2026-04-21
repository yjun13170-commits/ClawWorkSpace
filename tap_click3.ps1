Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Clicker {
    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int X, int Y);
    [DllImport("user32.dll")]
    public static extern void mouse_event(uint dwFlags, int dx, int dy, int cButtons, int dwExtraInfo);
    public const uint LEFTDOWN = 0x02;
    public const uint LEFTUP = 0x04;
    public static void Click(int x, int y) {
        SetCursorPos(x, y);
        System.Threading.Thread.Sleep(100);
        mouse_event(LEFTDOWN, 0, 0, 0, 0);
        System.Threading.Thread.Sleep(50);
        mouse_event(LEFTUP, 0, 0, 0, 0);
    }
}
"@

# Emulator window: 1629,311 - 2250,925 (621x614)
# Phone display roughly: 1680,360 - 2190,870
# Button center: ~ (1935, 630)
Write-Host "Clicking at (1935, 630)"
[Clicker]::Click(1935, 630)
Start-Sleep -Seconds 3

# Screenshot
Add-Type -AssemblyName System.Windows.Forms
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bmp = New-Object System.Drawing.Bitmap($screen.Width, $screen.Height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($screen.Location, [System.Drawing.Point]::Empty, $bmp.Size)
$bmp.Save("C:\Users\hci\.openclaw\workspace\screenshot_after_click3.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
Write-Host "Done"

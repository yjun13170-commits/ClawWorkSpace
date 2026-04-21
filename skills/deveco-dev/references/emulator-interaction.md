# Emulator Interaction via Windows Mouse Events

## Problem

hdc 没有 `input tap` / `input click` 命令，无法通过 hdc shell 模拟点击模拟器内的控件。

## Solution

通过 Windows API 模拟鼠标点击，利用模拟器窗口的屏幕坐标来间接操作模拟器内部。

### Step 1: Find Emulator Window Position

```powershell
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

$emulator = Get-Process | Where-Object { $_.MainWindowTitle -eq 'Emulator' } | Select-Object -First 1
$rect = New-Object RECT
[WinInfo]::GetWindowRect($emulator.MainWindowHandle, [ref]$rect) | Out-Null
Write-Host "Emulator window: $($rect.Left),$($rect.Top)-$($rect.Right),$($rect.Bottom)"
```

### Step 2: Calculate Click Coordinates

Emulator 窗口内包含边框和工具栏，手机屏幕实际区域约为窗口内部的居中区域。

**经验值：**
- Emulator 窗口标题为 "Emulator"
- 手机屏幕区域 ≈ 窗口内部中心区域
- 需要根据截图分析估算具体按钮坐标

### Step 3: Click with Multi-Position Fallback

```powershell
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

# 在多个 Y 坐标尝试，增加命中率
$positions = @(
    @(1935, 580),
    @(1935, 620),
    @(1935, 660),
    @(1935, 700)
)

foreach ($pos in $positions) {
    [Clicker]::Click($pos[0], $pos[1])
    Start-Sleep -Milliseconds 500
}
```

### Step 4: Verify with Screenshot

点击后等待 2-3 秒，截图确认是否成功跳转。

### Important Notes

- **多位置尝试**是关键：单个坐标可能错过，多个 Y 值增加命中概率
- 每次点击间隔 500ms，避免过快
- 点击后等待 2-3 秒再截图验证，给页面跳转留出时间
- 坐标基于当前桌面布局，窗口移动后需要重新估算
- **hdc 没有 input tap** — 必须用 Windows 模拟点击
- 模拟器窗口标题为 "Emulator"，用 `Get-Process` 查找

## Notifying the User

Use `need_help.ps1` script in workspace root:
```
powershell -ExecutionPolicy Bypass -File need_help.ps1 -Message "task complete or need help" -TaskId "unique_id"
```

Notification has 3 layers: system beeps, desktop file, topmost dialog via schtasks.
Dialog buttons: 我来处理 (OK=stop), 你自己搞定 (Cancel=continue).
Check `task_flags/STOP.flag` before sending another notification.

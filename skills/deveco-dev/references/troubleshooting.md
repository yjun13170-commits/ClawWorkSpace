# Troubleshooting

## Build Failures

### `Invalid value of 'DEVECO_SDK_HOME'`
Fix: `set DEVECO_SDK_HOME=C:\Program Files\Huawei\DevEco Studio\sdk`

### `spawn java ENOENT`
Fix: `set JAVA_HOME=C:\Program Files\Huawei\DevEco Studio\jbr` and add `%JAVA_HOME%\bin` to PATH

### `SDK component missing`
Verify SDK path exists. The IDE-bundled SDK is at `C:\Program Files\Huawei\DevEco Studio\sdk`.

## PowerShell Issues

- `2>nul` redirect fails in PowerShell — use `cmd /c` wrapper or avoid redirects
- Multi-byte characters (Chinese) in PowerShell inline commands cause encoding errors — use script files instead
- `cmd /c` inside PowerShell gets mangled — use `.bat` files for complex cmd chains

## App Not Updating on Emulator

Old HAP was installed without rebuilding. Always rebuild after code changes:
1. Clean old build: delete `entry/build/default/` directory
2. Rebuild with correct env vars
3. Install new HAP
4. Launch app

## Device/Emulator Connection

- Check with: `hdc list targets`
- Default emulator: `127.0.0.1:5555`
- If not connected, start emulator from Device Manager in DevEco Studio

## Bundle Name

Format: `com.example.<project_dir_name>`
- MyApplication → `com.example.myapplication`

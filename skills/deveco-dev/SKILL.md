---
name: deveco-dev
description: "DevEco Studio 开发技能 — HarmonyOS 应用的代码修改、构建、安装和模拟器运行。当用户要求修改 DevEco 项目代码、构建 HAP、安装到模拟器/真机、运行/调试应用、查看报错信息时使用。"
---

# DevEco Dev

## Environment Paths

```
DEVECO_HOME     = C:\Program Files\Huawei\DevEco Studio
SDK_PATH        = C:\Program Files\Huawei\DevEco Studio\sdk
USER_SDK        = C:\Users\hci\AppData\Local\Huawei\Sdk
JBR_PATH        = C:\Program Files\Huawei\DevEco Studio\jbr
HDC             = %DEVECO_HOME%\sdk\default\openharmony\toolchains\hdc.exe
HVIGORW         = %DEVECO_HOME%\tools\hvigor\bin\hvigorw.bat
PROJECTS_DIR    = C:\Users\hci\DevEcoStudioProjects
```

## Core Workflows

### 1. Read/Edit Code

Project structure:
```
PROJECTS_DIR/<project>/
├── entry/src/main/ets/pages/Index.ets   # main page
├── entry/src/main/resources/            # assets
├── build-profile.json5                  # build config
└── entry/build/default/outputs/default/ # output HAP files
```

### 2. Build HAP

Must set env vars first. Use `rebuild.bat` script:

```bash
# Run rebuild script (handles all env setup)
scripts/rebuild.bat
```

If script doesn't exist, create it or run inline:
```
set DEVECO_SDK_HOME=%DEVECO_HOME%\sdk
set JAVA_HOME=%JBR_PATH%
set PATH=%JAVA_HOME%\bin;%PATH%
cd /d <project-dir>
"HVIGORW" -p module=entry@default -p product=default assembleHap --no-daemon
```

**Common build errors:**
- `DEVECO_SDK_HOME` invalid → set to `%DEVECO_HOME%\sdk`
- `spawn java ENOENT` → set `JAVA_HOME=%JBR_PATH%` and add to PATH
- SDK component missing → verify SDK_PATH exists

### 3. Install to Device/Emulator

```
hdc.exe list targets          # check connected devices
hdc.exe app install -p <hap-path>  # install HAP
```

HAP output path: `entry/build/default/outputs/default/entry-default-signed.hap`

### 4. Launch App

```
hdc.exe shell aa start -a EntryAbility -b com.example.<projectname>
```

Bundle name format: `com.example.<project_dir_name>`

### 5. Verify

Take screenshot after install+launch to confirm changes are visible.

### 6. Need Help / Notify User

**When to notify:** After completing a task, or when stuck and need user intervention.

**How:**
```
powershell -ExecutionPolicy Bypass -File need_help.ps1 -Message "task description" -TaskId "unique_id"
```

**Notification has 3 layers:**
1. System beeps (3 tones) to grab audio attention
2. Desktop file (`ji_ge_need_help.txt`) as visual fallback
3. Topmost dialog launched via `schtasks` as independent system task (survives parent exit)

**Dialog buttons:**
- **我来处理 (OK)** = User will handle it → agent stops, check `STOP.flag`
- **你自己搞定 (Cancel)** = Agent should continue trying

**Flag files in `task_flags/`:**
- `STOP.flag` exists → user will handle, agent should NOT notify again
- `<TaskId>.flag` = "user_will_handle" or "agent_continue"
- **Only call ONCE per task** — check STOP.flag before calling again

## Scripts

- `scripts/rebuild.bat` — full rebuild with correct env vars
- `scripts/install_and_run.ps1` — install HAP + launch app + screenshot

## References

- `references/troubleshooting.md` — common errors and fixes
- `references/hdc-commands.md` — useful hdc commands

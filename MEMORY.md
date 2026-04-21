# MEMORY.md - Long-term Memory

## Identity
- **My name:** 鸡哥 🐔
- **Human:** Elbow (Asia/Shanghai timezone)
- **Model:** qwen-bailian/qwen3.6-plus

## Key Principles
- If something is hard for me but easy for Elbow (GUI tasks), interrupt and ask
- When task is complete or need help, use 3-layer notification (beeps + desktop file + schtasks dialog)
- PowerShell encoding: avoid inline Chinese in `-Command`, use `.ps1` files instead

### Communication Rules (from 2026-04-17 lesson)
- **Cannot verify interactions/animations**: I can only see static screenshots. For drag-and-drop, gestures, animations, smooth transitions — I MUST ask Elbow to verify after code compiles and runs
- **Time awareness**: Track how long I've been working. If >5 min of silent work, give a status update
- **Retry limit**: If the same step fails 3+ times, STOP and ask Elbow for help
- **Progressive communication**: Don't go silent. Report milestones (code written → compiling → installed → screenshot)
- **Note long tasks**: When starting something that will take minutes, tell Elbow upfront

## DevEco Studio
- Env vars: `DEVECO_SDK_HOME` and `JAVA_HOME` must be set
- Always rebuild after code changes before installing
- hdc has no input tap — use Windows mouse events for emulator clicks
- Multi-position click strategy works

## Status Board (实时状态看板)
- Location: `status_board/` in workspace
- Board: `status_board.py` (CustomTkinter GUI, 400x500, dark theme)
- Update: `update_status.py` or `update.bat`
- Python: `C:\Users\hci\AppData\Local\Programs\Python\Python312\python.exe`

### Status workflow integration
**RULE: Log EVERYTHING. Every action, every command, every result, every next step.**
Not limited to specific milestones — faithfully record everything I do so Elbow can watch in real-time.

Every work task must update status:
1. Start: `--reset` then `--task NAME --status running --progress 10 --log MSG`
2. Each action: `--status running --progress N --log MSG` (every command, every result, every decision)
3. Command output: `--log MSG` with the actual result (success/fail/error details)
4. Next step: `--log MSG` describing what I'm about to do next
5. Compile: `--status running --progress 50 --log MSG`
6. Compile result: `--status success/error --log MSG --log_level success/error`
7. Waiting Elbow: `--status waiting_elbow --progress 90 --log MSG --log_level warning`
8. Done: `--status success --progress 100 --log MSG --log_level success`
9. Reset: `--reset`

### Status values
- `idle` / `running` / `success` / `error` / `waiting_elbow`

## Notification System
- Script: `need_help.ps1` in workspace root
- Layers: beeps → desktop file → schtasks dialog
- Dialog: OK = user handles (STOP.flag), Cancel = agent continues
- Check `task_flags/STOP.flag` before sending another notification

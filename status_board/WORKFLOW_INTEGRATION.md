# 状态看板 - 工作流集成文档

## 核心规则

**记录一切行为。不仅限于里程碑节点。**

鸡哥做的每一步操作、执行的每条命令、收到的每个结果、下一步打算做什么 —— 全部作为日志打印到看板上。让 Elbow 像坐旁边看屏幕一样透明。

## 状态更新工具

```bash
# 路径
C:\Users\hci\.openclaw\workspace\status_board\update.bat

# 或者直接用 Python
C:\Users\hci\AppData\Local\Programs\Python\Python312\python.exe C:\Users\hci\.openclaw\workspace\status_board\update_status.py [参数]
```

## 参数说明

| 参数 | 说明 | 示例 |
|------|------|------|
| `--task` | 当前任务名 | `--task "编译 HarmonyOS 应用"` |
| `--status` | 状态 | `idle` / `running` / `success` / `error` / `waiting_elbow` |
| `--progress` | 进度 0-100 | `--progress 60` |
| `--emoji` | 图标 | `--emoji "🔨"` |
| `--log` | 日志消息 | `--log "编译成功"` |
| `--log_level` | 日志级别 | `info` / `success` / `error` / `warning` |
| `--reset` | 重置为待机状态 | `--reset` |

## 鸡哥工作流集成点

### 1. 收到需求
```
update.bat --task "调研方案" --status running --progress 10 --log "收到需求，开始调研"
```

### 2. 开始编码
```
update.bat --task "编写代码" --status running --progress 20 --log "开始编写 ArkUI 代码" --log_level info
```

### 3. 开始编译
```
update.bat --task "编译构建" --status running --progress 50 --emoji "🔨" --log "开始编译 HAP"
```

### 4. 编译结果
```
# 成功
update.bat --task "安装到模拟器" --status running --progress 75 --log "编译成功" --log_level success

# 失败
update.bat --status error --progress 50 --emoji "❌" --log "编译失败：XXX" --log_level error
```

### 5. 安装完成
```
update.bat --task "等待验证" --status waiting_elbow --progress 90 --emoji "🙋" --log "已安装，请验证交互效果" --log_level warning
```

### 6. 完成推送
```
update.bat --task "任务完成" --status success --progress 100 --emoji "✅" --log "代码已推送" --log_level success
```

### 7. 任务结束，重置
```
update.bat --reset
```

## 约定

- 每次新任务开始先 `--reset` 清空日志
- 关键节点必须写 log（开始、编译结果、完成）
- 需要 Elbow 验证时必须设 status 为 `waiting_elbow`
- 任务完成后设 status 为 `success`，然后 reset

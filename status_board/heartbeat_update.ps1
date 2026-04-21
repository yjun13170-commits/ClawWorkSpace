$python = "C:\Users\hci\AppData\Local\Programs\Python\Python312\python.exe"
$script = "C:\Users\hci\.openclaw\workspace\status_board\update_status.py"

& $python $script --status running --progress 15 `
  --log "心跳检测：status.json最后更新于17:07:04，距开始已18.5分钟，GitHub同步任务仍在死循环中" `
  --log "日志分析：17:01-17:07期间开始同步代码到GitHub重复30+次，无任何实际进展" `
  --log "17:04:39首次检测死循环(15次)，17:06:21确认(20+次)，已向Elbow求助" `
  --log "当前状态：卡在GitHub同步，无新操作产出，等待Elbow介入" `
  --log_level warning

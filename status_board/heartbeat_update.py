import json
import os
from datetime import datetime

status_file = os.path.join(os.path.dirname(__file__), "status.json")

with open(status_file, "r", encoding="utf-8") as f:
    data = json.load(f)

now = datetime.now().strftime("%H:%M:%S")
new_logs = [
    {"time": now, "level": "info", "msg": "💓 心跳批量更新：检测到 status.json 有持续写入（17:01-17:07 GitHub同步循环）"},
    {"time": now, "level": "warning", "msg": "⚠️ 确认死循环：GitHub同步任务重复30+次，无任何实际进展，已运行18.5分钟"},
    {"time": now, "level": "error", "msg": "🆘 已向Elbow求助，等待介入。当前无新操作可执行。"},
    {"time": now, "level": "info", "msg": "状态维持 running，进度15%，等待Elbow下一步指示"}
]

data["logs"].extend(new_logs)
data["status"] = "running"
data["progress"] = 15
data["elapsed_sec"] = int((datetime.now() - datetime.fromisoformat(data["start_time"])).total_seconds())

with open(status_file, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Status board updated successfully")

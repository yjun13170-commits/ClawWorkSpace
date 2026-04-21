"""
鸡哥状态更新工具
在命令行或工作流中调用，写入 status.json 让看板实时刷新
"""

import json
import os
import sys
import time
from datetime import datetime

STATUS_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "status.json")


def update_status(task=None, status=None, progress=None, emoji=None, log_msg=None, log_level="info"):
    """更新状态，只修改传入的字段，保留其他字段"""
    data = {}
    if os.path.exists(STATUS_FILE):
        try:
            with open(STATUS_FILE, "r", encoding="utf-8") as f:
                data = json.load(f)
        except (json.JSONDecodeError, IOError):
            pass

    if task is not None:
        data["task"] = task
    if status is not None:
        data["status"] = status
    if progress is not None:
        data["progress"] = progress
    if emoji is not None:
        data["emoji"] = emoji
    if log_msg is not None:
        if "logs" not in data:
            data["logs"] = []
        now_str = datetime.now().strftime("%H:%M:%S")
        data["logs"].append({
            "time": now_str,
            "level": log_level,
            "msg": log_msg,
        })
    if status == "running" and data.get("start_time") is None:
        data["start_time"] = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")

    # 计算 elapsed
    if data.get("start_time"):
        try:
            start = datetime.fromisoformat(data["start_time"])
            data["elapsed_sec"] = int((datetime.now() - start).total_seconds())
        except (ValueError, TypeError):
            pass

    with open(STATUS_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    return data


def reset_status():
    """重置为初始状态"""
    data = {
        "task": "待命中",
        "status": "idle",
        "progress": 0,
        "start_time": None,
        "elapsed_sec": 0,
        "logs": [],
        "emoji": "💤",
    }
    with open(STATUS_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    return data


# ===== 命令行接口 =====
# python update_status.py --task "编译" --status running --progress 50 --log "开始编译"
# python update_status.py --reset

if __name__ == "__main__":
    args = sys.argv[1:]
    kwargs = {}
    i = 0
    while i < len(args):
        if args[i] == "--reset":
            reset_status()
            print("Status reset to idle")
            sys.exit(0)
        elif args[i].startswith("--"):
            key = args[i][2:]
            if i + 1 < len(args) and not args[i + 1].startswith("--"):
                kwargs[key] = args[i + 1]
                i += 2
            else:
                kwargs[key] = True
                i += 1
        else:
            i += 1

    # 映射参数
    update_args = {}
    if "task" in kwargs:
        update_args["task"] = kwargs["task"]
    if "status" in kwargs:
        update_args["status"] = kwargs["status"]
    if "progress" in kwargs:
        try:
            update_args["progress"] = int(kwargs["progress"])
        except ValueError:
            pass
    if "emoji" in kwargs:
        update_args["emoji"] = kwargs["emoji"]
    if "log" in kwargs:
        update_args["log_msg"] = kwargs["log"]
    if "log_level" in kwargs:
        update_args["log_level"] = kwargs["log_level"]

    if update_args:
        result = update_status(**update_args)
        # Print ASCII-safe output to avoid encoding issues
        print(f"OK: {result.get('task', '?')} [{result.get('status', '?')}]")
    else:
        print("Usage: update_status.py --task NAME --status STATUS --progress N --emoji E --log MSG --log_level LEVEL")
        print("   or: update_status.py --reset")

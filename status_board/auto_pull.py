"""
自动从 session transcript 提取工具调用，更新 status.json
不依赖鸡哥主动写入，自动拉取真实活动记录
"""

import json
import os
import sys
import glob
from datetime import datetime, timezone, timedelta

TRANSCRIPT_DIR = os.path.expandvars(
    r"C:\Users\hci\.openclaw\agents\main\sessions"
)
STATUS_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "status.json")
OFFSET_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".last_line")

# 过滤掉无意义的活动
NOISE_TOOLS = {"session_status", "sessions_list", "memory_search", "cron"}
NOISE_COMMANDS = ["auto_pull.py", ".last_line", "loop_detector.py", "heartbeat_update.py", "status_board.py", "need_help.ps1"]

# 工具标签
TOOL_LABELS = {
    "exec": "💻",
    "read": "📖",
    "write": "📝",
    "edit": "✏️",
    "web_search": "🔍",
    "web_fetch": "🌐",
    "browser": "🖥️",
    "message": "📧",
    "tts": "🔊",
    "gateway": "⚙️",
    "memory_get": "🧠",
    "nodes": "📱",
    "canvas": "🖼️",
    "process": "⏱️",
}


def find_latest_transcript():
    """找到最新的主会话 transcript 文件"""
    files = glob.glob(os.path.join(TRANSCRIPT_DIR, "*.jsonl"))
    if not files:
        return None
    return max(files, key=os.path.getmtime)


def parse_ts(ts_str):
    """解析时间戳 -> 北京时间 HH:MM:SS"""
    try:
        if ts_str.endswith("Z"):
            ts_str = ts_str[:-1] + "+00:00"
        dt = datetime.fromisoformat(ts_str)
        if dt.tzinfo:
            dt = dt.astimezone(timezone(timedelta(hours=8)))
        return dt.strftime("%H:%M:%S")
    except Exception:
        return "??:??:??"


def summarize(tool_name, args):
    """生成可读摘要"""
    try:
        if tool_name == "exec":
            cmd = args.get("command", "")
            if "hdc" in cmd:
                if "install" in cmd: return "安装HAP"
                if "uninstall" in cmd: return "卸载应用"
                if "snapshot" in cmd: return "模拟器截图"
                if "aa start" in cmd: return "启动应用"
                return f"hdc: {cmd[:40]}"
            if "git" in cmd:
                if "push" in cmd: return "推送GitHub"
                if "commit" in cmd: return "Git提交"
                if "clone" in cmd: return "克隆仓库"
                return f"git: {cmd[cmd.index('git')+4:cmd.index('git')+44] if 'git' in cmd else cmd[:40]}"
            if "Compress-Archive" in cmd or "zip" in cmd: return "打包文件"
            if "send_email" in cmd: return "发送邮件"
            if "pip install" in cmd: return f"pip install {cmd.split('pip install')[-1].strip()[:30]}"
            if "python" in cmd and ".py" in cmd:
                pyfile = cmd.split(".py")[0].split("\\")[-1].split("/")[-1] + ".py"
                return f"运行 {pyfile}"
            # 通用：显示命令前60字符
            clean = cmd.strip().replace("\n", " ")
            if len(clean) > 60:
                clean = clean[:57] + "..."
            return f"命令: {clean}"

        elif tool_name == "write":
            return f"写入 {os.path.basename(args.get('path', ''))}"

        elif tool_name == "edit":
            return f"修改 {os.path.basename(args.get('path', ''))}"

        elif tool_name == "read":
            return f"读取 {os.path.basename(args.get('path', ''))}"

        elif tool_name == "web_search":
            return f"搜索: {args.get('query', '')[:30]}"

        elif tool_name == "web_fetch":
            url = args.get('url', '')
            return f"抓取 {url[:40]}"

        elif tool_name == "message":
            to = args.get('target', args.get('to', ''))
            return f"发消息到 {to}" if to else "发送消息"

        elif tool_name == "browser":
            action = args.get('action', '')
            return f"浏览器: {action}"

    except Exception:
        pass
    return tool_name


def extract_tool_calls(filepath, start_line=0):
    """从 JSONL 提取有意义的工具调用"""
    entries = []
    with open(filepath, "r", encoding="utf-8", errors="replace") as f:
        for i, line in enumerate(f):
            if i < start_line:
                continue
            line = line.strip()
            if not line:
                continue
            try:
                data = json.loads(line)
            except json.JSONDecodeError:
                continue

            if data.get("type") != "message":
                continue

            msg = data.get("message", {})
            role = msg.get("role", "")
            content = msg.get("content", [])
            ts = parse_ts(data.get("timestamp", ""))

            # 用户消息
            if role == "user":
                text_parts = []
                for c in content:
                    if isinstance(c, dict) and c.get("type") == "text":
                        text = c.get("text", "").strip()
                        if 3 < len(text) < 120:
                            text_parts.append(text)
                if text_parts:
                    text = " ".join(text_parts)
                    entries.append({
                        "time": ts, "level": "info",
                        "msg": f"💬 {text}", "line": i,
                    })
                continue

            # 助手工具调用
            if role == "assistant":
                for c in content:
                    if isinstance(c, dict) and c.get("type") == "toolCall":
                        tool_name = c.get("name", "")
                        args = c.get("arguments", {})

                        # 过滤噪音
                        if tool_name in NOISE_TOOLS:
                            continue
                        if tool_name == "exec":
                            cmd = args.get("command", "")
                            if any(n in cmd for n in NOISE_COMMANDS):
                                continue

                        label = TOOL_LABELS.get(tool_name, f"[{tool_name}]")
                        summary = summarize(tool_name, args)

                        entries.append({
                            "time": ts, "level": "info",
                            "msg": f"{label} {summary}", "line": i,
                        })

    return entries


def main():
    transcript = find_latest_transcript()
    if not transcript:
        print("No transcript found")
        return

    # 读取上次处理到的行号
    last_line = 0
    if os.path.exists(OFFSET_FILE):
        try:
            with open(OFFSET_FILE, "r") as f:
                last_line = int(f.read().strip())
        except (ValueError, IOError):
            last_line = 0

    # 提取新活动
    entries = extract_tool_calls(transcript, last_line)
    if not entries:
        print("No new activity")
        return

    # 保存新行号
    new_last_line = max(e["line"] for e in entries) + 1
    with open(OFFSET_FILE, "w") as f:
        f.write(str(new_last_line))

    # 更新 status.json
    data = {}
    if os.path.exists(STATUS_FILE):
        try:
            with open(STATUS_FILE, "r", encoding="utf-8") as f:
                data = json.load(f)
        except (json.JSONDecodeError, IOError):
            pass

    if "logs" not in data:
        data["logs"] = []

    # 添加新条目
    for entry in entries:
        data["logs"].append({
            "time": entry["time"],
            "level": entry["level"],
            "msg": entry["msg"],
        })

    # 只保留最近 50 条
    if len(data["logs"]) > 50:
        data["logs"] = data["logs"][-50:]

    data["session_active"] = True

    with open(STATUS_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    # 死循环检测
    try:
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
        from loop_detector import check_loops
        check_loops(entries)
    except Exception as e:
        print(f"Loop detector error: {e}")

    print(f"Updated: {len(entries)} new entries (line {last_line} -> {new_last_line})")


if __name__ == "__main__":
    main()

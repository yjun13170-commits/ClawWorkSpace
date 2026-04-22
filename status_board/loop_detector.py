"""
死循环检测器
分析 status.json 中的日志，检测连续重复命令。
策略：
  1. 首次检测到重复>=20次 → 警告 + 标记"已切换策略"
  2. 策略变更后再次检测到重复>=20次 → 中断任务 + 求助 Elbow
"""

import json
import os
from collections import Counter
from datetime import datetime

STATUS_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "status.json")
LOOP_STATE_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".loop_state")

LOOP_THRESHOLD = 20


def load_state():
    """加载循环检测状态"""
    if os.path.exists(LOOP_STATE_FILE):
        try:
            with open(LOOP_STATE_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass
    return {"detected": False, "strategy_changed": False, "loop_cmd": None}


def save_state(state):
    with open(LOOP_STATE_FILE, "w", encoding="utf-8") as f:
        json.dump(state, f, ensure_ascii=False, indent=2)


def check_loops(new_entries):
    """
    被 auto_pull.py 调用，检测死循环。
    new_entries: 本轮新增的条目列表
    """
    if not os.path.exists(STATUS_FILE):
        return

    with open(STATUS_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)

    logs = data.get("logs", [])
    if len(logs) < LOOP_THRESHOLD:
        # 日志不够，不可能死循环
        state = load_state()
        if state.get("detected"):
            state = {"detected": False, "strategy_changed": False, "loop_cmd": None}
            save_state(state)
        return

    # 检查最近20条日志是否有大量重复
    recent_msgs = [l.get("msg", "") for l in logs[-LOOP_THRESHOLD:]]
    counter = Counter(recent_msgs)
    most_common_msg, most_common_count = counter.most_common(1)[0]

    if most_common_count < LOOP_THRESHOLD:
        # 没有死循环，重置状态
        state = load_state()
        if state.get("detected"):
            state = {"detected": False, "strategy_changed": False, "loop_cmd": None}
            save_state(state)
        return

    # 发现死循环！
    now_str = datetime.now().strftime("%H:%M:%S")
    state = load_state()

    if state.get("detected") and state.get("strategy_changed"):
        # 第二次：策略变更后仍然死循环 → 中断+求助
        data["status"] = "error"
        data["emoji"] = "🆘"
        data["logs"].append({
            "time": now_str,
            "level": "error",
            "msg": f"🆘 死循环确认（{most_common_count}次重复）！任务已中断，请求 Elbow 介入！"
        })
        if len(data["logs"]) > 20:
            data["logs"] = data["logs"][-20:]
        print(f"[LOOP] ESCALATED: {most_common_msg[:60]} 重复{most_common_count}次")
    elif not state.get("detected"):
        # 第一次检测到
        state["detected"] = True
        state["strategy_changed"] = False
        state["loop_cmd"] = most_common_msg
        data["logs"].append({
            "time": now_str,
            "level": "warning",
            "msg": f"⚠️ 检测到死循环（重复{most_common_count}次）：{most_common_msg[:60]}"
        })
        if len(data["logs"]) > 20:
            data["logs"] = data["logs"][-20:]
        print(f"[LOOP] DETECTED: {most_common_msg[:60]} 重复{most_common_count}次")
    else:
        # 已检测到但策略尚未变更 → 触发策略变更
        state["strategy_changed"] = True
        state["strategy_changed_at"] = now_str
        data["logs"].append({
            "time": now_str,
            "level": "warning",
            "msg": "🔄 已切换执行策略，重试中..."
        })
        if len(data["logs"]) > 20:
            data["logs"] = data["logs"][-20:]
        print(f"[LOOP] STRATEGY CHANGED: {most_common_msg[:60]}")

    # 写入状态
    with open(STATUS_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    save_state(state)

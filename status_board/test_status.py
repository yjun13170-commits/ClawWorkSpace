"""
测试脚本：模拟鸡哥写入状态数据
运行后看板窗口会实时更新
"""

import json
import os
import time

STATUS_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "status.json")

def write_status(data):
    with open(STATUS_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"[{data.get('task', '?')}] status updated")

if __name__ == "__main__":
    start = time.time()

    # 1. 初始状态
    write_status({
        "task": "待命中",
        "status": "idle",
        "progress": 0,
        "start_time": None,
        "elapsed_sec": 0,
        "logs": [{"time": "15:30:00", "level": "info", "msg": "看板启动，等待任务"}],
        "emoji": "💤",
    })
    time.sleep(2)

    # 2. 开始工作
    write_status({
        "task": "编写 HarmonyOS 页面",
        "status": "running",
        "progress": 10,
        "start_time": "2026-04-21T15:30:05",
        "elapsed_sec": 5,
        "logs": [
            {"time": "15:30:00", "level": "info", "msg": "看板启动，等待任务"},
            {"time": "15:30:05", "level": "info", "msg": "收到需求，开始调研"},
        ],
        "emoji": "🔍",
    })
    time.sleep(3)

    # 3. 编码中
    write_status({
        "task": "编写 ArkUI 组件",
        "status": "running",
        "progress": 45,
        "start_time": "2026-04-21T15:30:05",
        "elapsed_sec": 30,
        "logs": [
            {"time": "15:30:00", "level": "info", "msg": "看板启动，等待任务"},
            {"time": "15:30:05", "level": "info", "msg": "收到需求，开始调研"},
            {"time": "15:30:15", "level": "info", "msg": "开始编写代码"},
            {"time": "15:30:30", "level": "info", "msg": "组件编码中..."},
        ],
        "emoji": "✏️",
    })
    time.sleep(3)

    # 4. 编译中
    write_status({
        "task": "编译构建 HAP",
        "status": "running",
        "progress": 70,
        "start_time": "2026-04-21T15:30:05",
        "elapsed_sec": 60,
        "logs": [
            {"time": "15:30:00", "level": "info", "msg": "看板启动，等待任务"},
            {"time": "15:30:05", "level": "info", "msg": "收到需求，开始调研"},
            {"time": "15:30:15", "level": "info", "msg": "开始编写代码"},
            {"time": "15:30:30", "level": "info", "msg": "组件编码中..."},
            {"time": "15:31:05", "level": "info", "msg": "代码写完，开始编译"},
        ],
        "emoji": "🔨",
    })
    time.sleep(3)

    # 5. 编译成功
    write_status({
        "task": "安装到模拟器",
        "status": "running",
        "progress": 85,
        "start_time": "2026-04-21T15:30:05",
        "elapsed_sec": 90,
        "logs": [
            {"time": "15:30:00", "level": "info", "msg": "看板启动，等待任务"},
            {"time": "15:30:05", "level": "info", "msg": "收到需求，开始调研"},
            {"time": "15:30:15", "level": "info", "msg": "开始编写代码"},
            {"time": "15:30:30", "level": "info", "msg": "组件编码中..."},
            {"time": "15:31:05", "level": "info", "msg": "代码写完，开始编译"},
            {"time": "15:31:35", "level": "success", "msg": "编译成功！"},
        ],
        "emoji": "📦",
    })
    time.sleep(3)

    # 6. 等待验证
    write_status({
        "task": "等待 Elbow 验证交互效果",
        "status": "waiting_elbow",
        "progress": 90,
        "start_time": "2026-04-21T15:30:05",
        "elapsed_sec": 120,
        "logs": [
            {"time": "15:30:00", "level": "info", "msg": "看板启动，等待任务"},
            {"time": "15:30:05", "level": "info", "msg": "收到需求，开始调研"},
            {"time": "15:30:15", "level": "info", "msg": "开始编写代码"},
            {"time": "15:30:30", "level": "info", "msg": "组件编码中..."},
            {"time": "15:31:05", "level": "info", "msg": "代码写完，开始编译"},
            {"time": "15:31:35", "level": "success", "msg": "编译成功！"},
            {"time": "15:32:05", "level": "success", "msg": "HAP 安装完成"},
            {"time": "15:32:05", "level": "warning", "msg": "🙋 请 Elbow 验证拖拽交互效果"},
        ],
        "emoji": "🙋",
    })
    time.sleep(3)

    # 7. 完成
    write_status({
        "task": "折叠屏拖拽发图 - 已完成",
        "status": "success",
        "progress": 100,
        "start_time": "2026-04-21T15:30:05",
        "elapsed_sec": 180,
        "logs": [
            {"time": "15:30:00", "level": "info", "msg": "看板启动，等待任务"},
            {"time": "15:30:05", "level": "info", "msg": "收到需求，开始调研"},
            {"time": "15:30:15", "level": "info", "msg": "开始编写代码"},
            {"time": "15:30:30", "level": "info", "msg": "组件编码中..."},
            {"time": "15:31:05", "level": "info", "msg": "代码写完，开始编译"},
            {"time": "15:31:35", "level": "success", "msg": "编译成功！"},
            {"time": "15:32:05", "level": "success", "msg": "HAP 安装完成"},
            {"time": "15:32:05", "level": "warning", "msg": "🙋 请 Elbow 验证拖拽交互效果"},
            {"time": "15:33:05", "level": "success", "msg": "✅ 交互验证通过，已推送代码"},
        ],
        "emoji": "✅",
    })

    print("\n✅ 测试完成！看板应已展示全部状态流程。")

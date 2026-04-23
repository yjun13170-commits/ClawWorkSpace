"""
鸡哥状态看板 - Status Board v2
实时显示 OpenClaw 工作状态
"""

import customtkinter as ctk
import json
import os
import time
from datetime import datetime
from threading import Thread

# 配置
STATUS_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "status.json")
POLL_INTERVAL = 1.0  # 刷新间隔（秒）
WINDOW_WIDTH = 400
WINDOW_HEIGHT = 500

# 状态颜色映射
STATUS_COLORS = {
    "idle": ("#808080", "灰色"),
    "running": ("#3B8ED0", "蓝色"),
    "success": ("#1DB954", "绿色"),
    "error": ("#E74C3C", "红色"),
    "waiting_elbow": ("#F39C12", "橙色"),
}

# 状态图标
STATUS_ICONS = {
    "idle": "💤",
    "running": "🔨",
    "success": "✅",
    "error": "❌",
    "waiting_elbow": "🙋",
}


class StatusBoard(ctk.CTk):
    def __init__(self):
        super().__init__()

        # 窗口配置
        self.title("🐔 鸡哥工作状态")
        self.geometry(f"{WINDOW_WIDTH}x{WINDOW_HEIGHT}")
        self.minsize(320, 400)
        self.attributes("-topmost", True)
        self.pinned = True  # 默认置顶

        # 主题
        ctk.set_appearance_mode("dark")
        ctk.set_default_color_theme("blue")

        # 当前状态缓存
        self.current_status = {
            "task": "待命中",
            "status": "idle",
            "progress": 0,
            "start_time": None,
            "elapsed_sec": 0,
            "logs": [],
            "emoji": "💤",
        }

        # 本地实时计时器（每秒刷新，不依赖 JSON）
        self.timer_start = None  # 任务开始时间（datetime）
        self._timer_running = False

        # 拖拽支持
        self.drag_start_x = 0
        self.drag_start_y = 0

        self._build_ui()
        self._bind_drag()
        self._load_status()

        # 启动轮询线程
        self.polling = True
        Thread(target=self._poll_loop, daemon=True).start()

        # 启动本地实时计时（每秒刷新）
        self._timer_running = True
        self._tick_timer()

    def _build_ui(self):
        # ===== 自定义标题栏 =====
        title_bar = ctk.CTkFrame(self, fg_color="#1E1E2E", height=36)
        title_bar.pack(fill="x", side="top")
        title_bar.pack_propagate(False)

        # 标题文字
        title_label = ctk.CTkLabel(
            title_bar,
            text="🐔 鸡哥工作状态",
            font=("Microsoft YaHei UI", 14, "bold"),
            text_color="#FFFFFF",
            anchor="w",
        )
        title_label.place(x=12, y=6)

        # 置顶按钮
        self.pin_btn = ctk.CTkButton(
            title_bar,
            text="📌",
            width=32,
            height=24,
            font=("", 12),
            fg_color="transparent",
            hover_color="#3B3B4F",
            text_color="#3B8ED0",
            command=self._toggle_pin,
        )
        self.pin_btn.place(x=WINDOW_WIDTH - 70, y=6)

        # 最小化按钮
        min_btn = ctk.CTkButton(
            title_bar,
            text="—",
            width=32,
            height=24,
            font=("", 16),
            fg_color="transparent",
            hover_color="#3B3B4F",
            text_color="#FFFFFF",
            command=lambda: self.state("iconic"),
        )
        min_btn.place(x=WINDOW_WIDTH - 38, y=6)

        # ===== 主内容区 =====
        self.main_frame = ctk.CTkFrame(self, fg_color="#16161E")
        self.main_frame.pack(fill="both", expand=True, padx=8, pady=4)

        # --- 状态卡片 ---
        self.status_card = ctk.CTkFrame(self.main_frame, fg_color="#1E1E2E", corner_radius=12)
        self.status_card.pack(fill="x", pady=(8, 4), padx=4)

        # 状态图标 + 文字
        self.status_top = ctk.CTkFrame(self.status_card, fg_color="transparent")
        self.status_top.pack(fill="x", padx=16, pady=(12, 4))

        self.icon_label = ctk.CTkLabel(
            self.status_top,
            text="💤",
            font=("", 28),
            width=40,
            anchor="w",
        )
        self.icon_label.pack(side="left")

        self.task_label = ctk.CTkLabel(
            self.status_top,
            text="待命中",
            font=("Microsoft YaHei UI", 16, "bold"),
            text_color="#FFFFFF",
            anchor="w",
        )
        self.task_label.pack(side="left", padx=(8, 0), fill="x", expand=True)

        self.status_label = ctk.CTkLabel(
            self.status_top,
            text="待机",
            font=("Microsoft YaHei UI", 12),
            text_color="#808080",
            anchor="e",
        )
        self.status_label.pack(side="right")

        # 进度条
        self.progress_bar = ctk.CTkProgressBar(
            self.status_card,
            width=360,
            height=8,
            corner_radius=4,
            progress_color="#3B8ED0",
            fg_color="#2A2A3E",
        )
        self.progress_bar.pack(padx=16, pady=(0, 4))
        self.progress_bar.set(0)

        # 耗时
        self.time_label = ctk.CTkLabel(
            self.status_card,
            text="⏱️ 00:00",
            font=("Consolas", 12),
            text_color="#666680",
            anchor="w",
        )
        self.time_label.pack(anchor="w", padx=16, pady=(0, 12))

        # --- 活动日志 ---
        log_header = ctk.CTkLabel(
            self.main_frame,
            text="📜 活动日志",
            font=("Microsoft YaHei UI", 13, "bold"),
            text_color="#CCCCCC",
            anchor="w",
        )
        log_header.pack(anchor="w", padx=12, pady=(12, 4))

        # 日志滚动区
        self.log_frame = ctk.CTkFrame(self.main_frame, fg_color="#1E1E2E", corner_radius=8)
        self.log_frame.pack(fill="both", expand=True, padx=8, pady=(0, 8))

        self.log_canvas = ctk.CTkScrollableFrame(
            self.log_frame,
            fg_color="transparent",
            label_fg_color="transparent",
        )
        self.log_canvas.pack(fill="both", expand=True, padx=4, pady=4)

        # 日志条目列表
        self.log_widgets = []

        # 底部信息
        footer = ctk.CTkLabel(
            self.main_frame,
            text="上次更新: --",
            font=("Consolas", 10),
            text_color="#444460",
        )
        footer.pack(anchor="e", padx=12, pady=(0, 4))
        self.footer = footer

    def _bind_drag(self):
        """绑定标题栏拖拽"""
        title_bar = self.winfo_children()[0]

        def on_press(event):
            self.drag_start_x = event.x_root - self.winfo_x()
            self.drag_start_y = event.y_root - self.winfo_y()

        def on_drag(event):
            x = event.x_root - self.drag_start_x
            y = event.y_root - self.drag_start_y
            self.geometry(f"+{x}+{y}")

        title_bar.bind("<Button-1>", on_press)
        title_bar.bind("<B1-Motion>", on_drag)
        for child in title_bar.winfo_children():
            child.bind("<Button-1>", on_press)
            child.bind("<B1-Motion>", on_drag)

    def _toggle_pin(self):
        self.pinned = not self.pinned
        self.attributes("-topmost", self.pinned)
        self.pin_btn.configure(
            text="📌" if self.pinned else "📍",
            text_color="#3B8ED0" if self.pinned else "#FFFFFF",
        )

    def _load_status(self):
        """从 status.json 加载初始状态"""
        try:
            if os.path.exists(STATUS_FILE):
                with open(STATUS_FILE, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    self.current_status.update(data)
                    # 初始化时渲染日志
                    for entry in data.get("logs", []):
                        self._add_log_entry(entry)
                    # 更新状态卡片
                    status = data.get("status", "idle")
                    task = data.get("task", "待命中")
                    progress = data.get("progress", 0)
                    emoji = data.get("emoji", STATUS_ICONS.get(status, "💤"))
                    self.icon_label.configure(text=emoji)
                    self.task_label.configure(text=task)
                    color, label = STATUS_COLORS.get(status, ("#808080", "未知"))
                    self.status_label.configure(text=label, text_color=color)
                    self.progress_bar.configure(progress_color=color)
                    self.progress_bar.set(min(progress / 100.0, 1.0))

                    # 如果任务在运行，启动本地计时
                    if status == "running":
                        self.timer_start = datetime.now()
                        elapsed = data.get("elapsed_sec", 0)
                        mins, secs = divmod(int(elapsed), 60)
                        self.time_label.configure(text=f"⏱️ {mins:02d}:{secs:02d}")
        except (json.JSONDecodeError, IOError):
            pass

    def _poll_loop(self):
        """后台轮询 status.json"""
        last_mtime = 0
        while self.polling:
            try:
                if os.path.exists(STATUS_FILE):
                    mtime = os.path.getmtime(STATUS_FILE)
                    if mtime != last_mtime:
                        last_mtime = mtime
                        with open(STATUS_FILE, "r", encoding="utf-8") as f:
                            data = json.load(f)
                            self.after(0, lambda d=data: self._update_ui(d))
            except (json.JSONDecodeError, IOError, OSError):
                pass
            time.sleep(POLL_INTERVAL)

    def _update_ui(self, data: dict):
        """更新 UI（必须在主线程调用）"""
        old_logs_len = len(self.current_status.get("logs", []))
        old_status = self.current_status.get("status", "idle")

        self.current_status.update(data)

        status = data.get("status", "idle")
        task = data.get("task", "待命中")
        progress = data.get("progress", 0)
        emoji = data.get("emoji", STATUS_ICONS.get(status, "💤"))

        # 任务开始时启动本地计时
        if status == "running" and old_status != "running":
            self.timer_start = datetime.now()

        # 任务结束时停止计时
        if status in ("success", "error", "idle") and old_status == "running" and self.timer_start is not None:
            elapsed = int((datetime.now() - self.timer_start).total_seconds())
            self.current_status["elapsed_sec"] = elapsed
            # 计算耗时字符串
            mins, secs = divmod(elapsed, 60)
            hours, mins_rem = divmod(mins, 60)
            if hours > 0:
                elapsed_str = f"{hours:02d}:{mins_rem:02d}:{secs:02d}"
            else:
                elapsed_str = f"{mins_rem:02d}:{secs:02d}"
            # 去重：如果 update_status.py 已写入耗时日志则不再追加
            data.setdefault("logs", [])
            has_elapsed = any("任务耗时" in entry.get("msg", "") for entry in data["logs"])
            if not has_elapsed:
                now_str = datetime.now().strftime("%H:%M:%S")
                data["logs"].append({
                    "time": now_str,
                    "level": "info",
                    "msg": f"⏱️ 任务耗时: {elapsed_str}",
                })
                if len(data["logs"]) > 20:
                    data["logs"] = data["logs"][-20:]
                # 保存回 status.json
                try:
                    with open(STATUS_FILE, "w", encoding="utf-8") as f:
                        json.dump(data, f, ensure_ascii=False, indent=2)
                except IOError:
                    pass
            # 停止计时器
            self.timer_start = None
            # 显示最终耗时
            self.time_label.configure(text=f"⏱️ {elapsed_str}")

        # 更新状态卡片
        self.icon_label.configure(text=emoji)
        self.task_label.configure(text=task)

        color, label = STATUS_COLORS.get(status, ("#808080", "未知"))
        self.status_label.configure(text=label, text_color=color)
        self.progress_bar.configure(progress_color=color)
        self.progress_bar.set(min(progress / 100.0, 1.0))

        # 更新日志 - 只添加新条目
        logs = data.get("logs", [])
        if len(logs) > old_logs_len:
            for entry in logs[old_logs_len:]:
                self._add_log_entry(entry)

        # 自动滚动到底部
        self.after(50, self._scroll_to_bottom)

        # 更新底部时间戳
        now_str = datetime.now().strftime("%H:%M:%S")
        self.footer.configure(text=f"上次更新: {now_str}")

    def _add_log_entry(self, entry: dict):
        """添加一条日志"""
        level_colors = {
            "info": "#8888AA",
            "success": "#1DB954",
            "error": "#E74C3C",
            "warning": "#F39C12",
        }
        level_icons = {
            "info": "·",
            "success": "✓",
            "error": "✗",
            "warning": "!",
        }

        row = ctk.CTkFrame(self.log_canvas, fg_color="transparent")
        row.pack(fill="x", pady=1)

        time_str = entry.get("time", "--:--:--")
        level = entry.get("level", "info")
        msg = entry.get("msg", "")

        ctk.CTkLabel(
            row,
            text=time_str,
            font=("Consolas", 11),
            text_color="#555570",
            width=65,
            anchor="w",
        ).pack(side="left")

        icon = level_icons.get(level, "·")
        color = level_colors.get(level, "#8888AA")
        ctk.CTkLabel(
            row,
            text=f" {icon} {msg}",
            font=("Microsoft YaHei UI", 11),
            text_color=color,
            anchor="w",
        ).pack(side="left", fill="x", expand=True)

        self.log_widgets.append(row)

    def _tick_timer(self):
        """本地实时计时，每秒刷新一次，不依赖 JSON 更新"""
        if not self._timer_running:
            return

        if self.timer_start is not None:
            elapsed = int((datetime.now() - self.timer_start).total_seconds())
            mins, secs = divmod(elapsed, 60)
            hours, mins = divmod(mins, 60)
            if hours > 0:
                text = f"⏱️ {hours:02d}:{mins:02d}:{secs:02d}"
            else:
                text = f"⏱️ {mins:02d}:{secs:02d}"
            self.time_label.configure(text=text)

        self.after(1000, self._tick_timer)

    def _scroll_to_bottom(self):
        """滚动到日志最底部"""
        try:
            canvas = self.log_canvas._parent_canvas
            if canvas:
                canvas.yview_moveto(1.0)
        except Exception:
            pass

    def on_close(self):
        self.polling = False
        self.destroy()


if __name__ == "__main__":
    app = StatusBoard()
    app.protocol("WM_DELETE_WINDOW", app.on_close)
    app.mainloop()

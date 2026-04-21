@echo off
title 🐔 鸡哥状态看板
set PYTHON="C:\Users\hci\AppData\Local\Programs\Python\Python312\python.exe"
cd /d "%~dp0"

:: 先重置状态
powershell -NoProfile -Command "& { $env:PYTHONIOENCODING='utf-8'; & %PYTHON% update_status.py --reset }"

echo 正在启动鸡哥状态看板...
%PYTHON% status_board.py

if errorlevel 1 (
    echo.
    echo ❌ 启动失败，按任意键退出...
    pause >nul
)

@echo off
:: 状态更新快捷脚本
:: 使用 PowerShell 避免中文编码问题
set PYTHON="C:\Users\hci\AppData\Local\Programs\Python\Python312\python.exe"
set SCRIPT_DIR=%~dp0
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $env:PYTHONIOENCODING='utf-8'; Set-Location '%SCRIPT_DIR%'; & %PYTHON% update_status.py %* }"

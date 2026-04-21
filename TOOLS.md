# Tools Cheat Sheet — 鸡哥的工具笔记

## DevEco Studio 构建
```
cd C:\Users\hci\DevEcoStudioProjects\MyApplication
call rebuild.bat
```
- 环境变量：`DEVECO_SDK_HOME` 和 `JAVA_HOME` 必须在 bat 里设置
- HAP 输出：`entry\build\default\outputs\default\entry-default-signed.hap`

## hdc 命令（模拟器 127.0.0.1:5555）
```
# 列出设备
hdc list targets

# 安装 HAP
hdc app install -p entry\build\default\outputs\default\entry-default-signed.hap

# 卸载
hdc app uninstall com.example.myapplication

# 启动应用
hdc shell aa start -a EntryAbility -b com.example.myapplication

# 截图（✅ 已验证可用）
hdc shell snapshot_display -f /data/local/tmp/screenshot.jpeg
hdc file recv /data/local/tmp/screenshot.jpeg "C:\Users\hci\DevEcoStudioProjects\MyApplication\screenshot.png"
```

## 脚本位置
- 构建：`scripts\rebuild.bat`
- 安装+运行+截图：`scripts\install_run_shot.bat`

## 项目路径
- 项目根目录：`C:\Users\hci\DevEcoStudioProjects\MyApplication`
- 主页面：`entry\src\main\ets\pages\Index.ets`

## GitHub 推送
- 账号：`yjun13170-commits`
- 仓库：`ClawWorkSpace`
- PAT 权限：fine-grained，只能 push 到指定仓库（不能创建新仓库）
- 推送流程：
```powershell
# 1. 克隆（PAT 嵌入 URL）
git clone https://yjun13170-commits:***REDACTED***@github.com/yjun13170-commits/ClawWorkSpace.git <local-path>
# 2. 复制代码到 clone 目录
# 3. git add/commit/push
```
- 远端获取：`git clone https://github.com/yjun13170-commits/ClawWorkSpace.git`

## 邮件发送
- 脚本：`skills\email-sender\send_email.ps1`
- 配置：`skills\email-sender\email_config.json`
- QQ邮箱：1003436117@qq.com，SMTP 授权码在 config 中
- 支持：纯文本 / 单文件附件 / 文件夹打包 zip 附件
```powershell
powershell -ExecutionPolicy Bypass -File "skills\email-sender\send_email.ps1" -To "目标邮箱" -Subject "标题" -Body "正文" -File "文件路径"
powershell -ExecutionPolicy Bypass -File "skills\email-sender\send_email.ps1" -To "目标邮箱" -Subject "标题" -Body "正文" -Folder "文件夹路径"
```

## 通知系统
- `need_help.ps1` 在 workspace 根目录
- 三层：蜂鸣 → 桌面文件 → schtasks dialog
- 检查 `task_flags\STOP.flag` 决定是否继续
- 用途：完成需要求助 Elbow 的任务，或通知任务完成

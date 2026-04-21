---
name: 邮件发送
description: "通过QQ邮箱SMTP发送邮件。支持单文件附件、文件夹打包为zip附件、纯文本邮件。当用户要求发邮件、发附件、发文件给某个邮箱时使用。"
metadata: {"requires":{"bins":["powershell"],"files":["skills/email-sender/send_email.ps1","skills/email-sender/email_config.json"]}}
---

# 邮件发送

通过 PowerShell + QQ邮箱 SMTP 发送邮件。

## 配置

- 脚本：`skills/email-sender/send_email.ps1`
- 配置：`skills/email-sender/email_config.json`（存发件人邮箱和SMTP授权码）
- SMTP 服务器：smtp.qq.com:587

## 用法

### 单文件附件

```powershell
powershell -File "C:\Users\hci\.openclaw\workspace\skills\email-sender\send_email.ps1" -To "目标邮箱" -Subject "标题" -Body "正文" -File "C:\path\to\file.txt"
```

### 文件夹打包为 zip 附件

```powershell
powershell -File "C:\Users\hci\.openclaw\workspace\skills\email-sender\send_email.ps1" -To "目标邮箱" -Subject "标题" -Body "正文" -Folder "C:\path\to\folder"
```

### 纯文本邮件（无附件）

```powershell
powershell -File "C:\Users\hci\.openclaw\workspace\skills\email-sender\send_email.ps1" -To "目标邮箱" -Subject "标题" -Body "正文"
```

## 参数

| 参数 | 必填 | 说明 |
|------|------|------|
| -To | 是 | 目标邮箱地址 |
| -Subject | 是 | 邮件标题 |
| -Body | 否 | 邮件正文（默认空） |
| -File | 否 | 单个文件作为附件 |
| -Folder | 否 | 文件夹，会自动打包为 zip 附件 |

## 输出

成功时输出 `EMAIL_SENT_OK` 及发送详情。
失败时输出错误信息，exit code 为 1。

## 注意事项

- `-File` 和 `-Folder` 可同时使用
- 文件夹打包会放在 `$env:TEMP` 下，文件名为 `文件夹名.zip`
- SMTP 授权码存在 `email_config.json` 中，注意保护隐私

# send_email.ps1 - QQ Email SMTP sender with attachment/zip support
param(
    [Parameter(Mandatory=$true)][string]$To,
    [Parameter(Mandatory=$true)][string]$Subject,
    [string]$Body = "",
    [string]$File = "",
    [string]$Folder = ""
)

$smtpServer = "smtp.qq.com"
$smtpPort = 587
$from = "1003436117@qq.com"
$password = ""

# Load config
$configPath = Join-Path $PSScriptRoot "email_config.json"
if (Test-Path $configPath) {
    $config = Get-Content $configPath | ConvertFrom-Json
    $password = $config.password
    if ($config.from) { $from = $config.from }
}

if (-not $password) {
    Write-Error "SMTP password not configured"
    exit 1
}

$credential = New-Object System.Management.Automation.PSCredential($from, (ConvertTo-SecureString $password -AsPlainText -Force))

$attachments = @()

# Folder -> zip
if ($Folder -ne "") {
    if (-not (Test-Path $Folder)) {
        Write-Error "Folder not found: $Folder"
        exit 1
    }
    $folderName = (Get-Item $Folder).Name
    $zipPath = Join-Path $env:TEMP "${folderName}.zip"
    Compress-Archive -Path "$Folder\*" -DestinationPath $zipPath -Force
    Write-Host "Packed: $zipPath"
    $attachments += $zipPath
}

# Single file
if ($File -ne "") {
    if (-not (Test-Path $File)) {
        Write-Error "File not found: $File"
        exit 1
    }
    $attachments += $File
}

# Send
try {
    if ($attachments.Count -gt 0) {
        Send-MailMessage -From $from -To $To -Subject $Subject -Body $Body -Encoding UTF8 -SmtpServer $smtpServer -Port $smtpPort -Credential $credential -UseSsl -Attachments $attachments
    } else {
        Send-MailMessage -From $from -To $To -Subject $Subject -Body $Body -Encoding UTF8 -SmtpServer $smtpServer -Port $smtpPort -Credential $credential -UseSsl
    }
    Write-Host "EMAIL_SENT_OK"
    Write-Host "To: $To"
    Write-Host "Subject: $Subject"
    Write-Host "Attachments: $($attachments -join ', ')"
} catch {
    Write-Error "Send failed: $_"
    exit 1
}

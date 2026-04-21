param([string]$Mode = "heartbeat")

$statusFile = "C:\Users\hci\.openclaw\workspace\status_board\status.json"

$jsonStr = Get-Content $statusFile -Raw -Encoding UTF8
$json = $jsonStr | ConvertFrom-Json

$now = (Get-Date).ToString("HH:mm:ss")

$newLog = @{
    time = $now
    level = "info"
    msg = "heartbeat: building still in progress, not stuck"
}

# Convert to JSON array, add new log
$logsArr = @()
foreach ($log in $json.logs) {
    $logsArr += @{
        time = $log.time
        level = $log.level
        msg = $log.msg
    }
}
$logsArr += $newLog

$output = @{
    task = $json.task
    status = $json.status
    progress = $json.progress
    start_time = $json.start_time
    elapsed_sec = [math]::Round((New-TimeSpan -Start ([datetime]::Parse($json.start_time)) -End (Get-Date)).TotalSeconds)
    logs = $logsArr
    emoji = $json.emoji
}

$output | ConvertTo-Json -Depth 5 | Set-Content $statusFile -Encoding UTF8

Write-Output "Synced heartbeat log at $now"

schtasks /End /TN "Openclaw Gateway"
Start-Sleep -Seconds 3
schtasks /Run /TN "Openclaw Gateway"

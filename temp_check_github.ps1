[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
try {
    $r = Invoke-WebRequest -Uri 'https://github.com' -UseBasicParsing -TimeoutSec 15
    Write-Output "OK: GitHub accessible, status $($r.StatusCode)"
} catch {
    Write-Output "FAIL: $_"
}

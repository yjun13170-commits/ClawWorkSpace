$env:Path += ";C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin"

Set-Location "C:\Users\hci\DevEcoStudioProjects\MyApplication"

# Build the hap using hvigorw
& "node.exe" "hvigor\hvigorw.js" -p module=entry@default -p product=default assembleHap --no-daemon

Write-Host "Build finished"

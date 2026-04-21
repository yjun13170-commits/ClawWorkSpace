$env:DEVECO_SDK_HOME = "C:\Users\hci\AppData\Local\Huawei\Sdk"
Set-Location "C:\Users\hci\DevEcoStudioProjects\MyApplication"
& "cmd.exe" "/c" "C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat" "-p" "module=entry@default" "-p" "product=default" "assembleHap" "--no-daemon"

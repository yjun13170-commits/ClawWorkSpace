@echo off
setlocal
set "DEVECO_SDK_HOME=C:\Program Files\Huawei\DevEco Studio\sdk"
set "JAVA_HOME=C:\Program Files\Huawei\DevEco Studio\jbr"
set "PATH=%JAVA_HOME%\bin;%PATH%"
cd /d "C:\Users\hci\DevEcoStudioProjects\MyApplication"
call "C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat" --stop-daemon
call "C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat" -p module=entry@default -p product=default assembleHap --no-daemon
endlocal

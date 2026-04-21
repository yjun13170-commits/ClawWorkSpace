@echo off
set DEVECO_SDK_HOME=C:\Program Files\Huawei\DevEco Studio\sdk
set JAVA_HOME=C:\Program Files\Huawei\DevEco Studio\jbr
set PATH=%JAVA_HOME%\bin;%PATH%
cd /d %1
if errorlevel 1 (
    echo Usage: rebuild.bat ^<project-dir^>
    exit /b 1
)
echo Building with DEVECO_SDK_HOME=%DEVECO_SDK_HOME%
echo JAVA_HOME=%JAVA_HOME%
"C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat" -p module=entry@default -p product=default assembleHap --no-daemon

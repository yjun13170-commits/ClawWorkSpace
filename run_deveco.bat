@echo off
set DEVECO_SDK_HOME=C:\Program Files\Huawei\DevEco Studio\sdk
set JAVA_HOME=C:\Program Files\Huawei\DevEco Studio\jbr
set PATH=%JAVA_HOME%\bin;%PATH%
cd /d C:\Users\hci\DevEcoStudioProjects\MyApplication

echo === Building ===
"C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat" -p module=entry@default -p product=default assembleHap --no-daemon
if errorlevel 1 (
    echo BUILD FAILED
    exit /b 1
)

echo === Installing ===
"C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe" app install -p "C:\Users\hci\DevEcoStudioProjects\MyApplication\entry\build\default\outputs\default\entry-default-signed.hap"

echo === Launching ===
"C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe" shell aa start -a EntryAbility -b com.example.myapplication

echo === Done ===

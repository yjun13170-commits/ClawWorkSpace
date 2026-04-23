@echo off
set HDC="C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe"
%HDC% app uninstall com.example.myapplication
%HDC% app install -p "C:\Users\hci\DevEcoStudioProjects\MyApplication\entry\build\default\outputs\default\entry-default-signed.hap"
%HDC% shell aa start -a EntryAbility -b com.example.myapplication
timeout /t 2 >nul
%HDC% shell snapshot_display -f /data/local/tmp/screenshot.jpeg
%HDC% file recv /data/local/tmp/screenshot.jpeg "C:\Users\hci\DevEcoStudioProjects\MyApplication\screenshot.png"
echo Done!

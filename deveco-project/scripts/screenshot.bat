@echo off
set HDC="C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe"
%HDC% shell snapshot_display -f /data/local/tmp/screenshot.jpeg
%HDC% file recv /data/local/tmp/screenshot.jpeg "C:\Users\hci\DevEcoStudioProjects\MyApplication\screenshot.png"
echo Screenshot saved!

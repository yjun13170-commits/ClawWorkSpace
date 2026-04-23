@echo off
set HDC="C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe"
%HDC% app uninstall com.example.myapplication
%HDC% app install -p "C:\Users\hci\DevEcoStudioProjects\MyApplication\entry\build\default\outputs\default\entry-default-signed.hap"

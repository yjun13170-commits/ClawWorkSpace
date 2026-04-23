@echo off
set HDC="C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe"
echo List root:
%HDC% shell ls /
echo Find screenshot tools:
%HDC% shell find /system/bin -name "*screen*" 2>nul
%HDC% shell find /system/bin -name "*snap*" 2>nul
echo Check data dir:
%HDC% shell ls /data/

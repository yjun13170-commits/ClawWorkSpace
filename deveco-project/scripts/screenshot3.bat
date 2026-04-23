@echo off
set HDC="C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe"
echo Attempt 1: snapshot
%HDC% shell snapshot display --file /data/media/screenshot.png
echo Attempt 2: screencap
%HDC% shell screencap /data/media/screenshot2.png
echo Attempt 3: list /data/media
%HDC% shell ls /data/media/

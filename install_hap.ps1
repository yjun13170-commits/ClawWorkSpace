$env:Path += ";C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains"

# Install the HAP file
Write-Host "Installing HAP..."
& "C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe" app install -p "C:\Users\hci\DevEcoStudioProjects\MyApplication\entry\build\default\outputs\default\entry-default-signed.hap"

Write-Host "Install finished"

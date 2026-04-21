# HDC Commands Reference

## Basic

```
hdc list targets                    # list connected devices
hdc shell                           # open shell on device
hdc shell ls /data/storage/el2/base # list app files
```

## App Management

```
hdc app install -p <hap-path>       # install HAP
hdc uninstall <bundle-name>         # uninstall app
hdc shell aa start -a <ability> -b <bundle>   # start ability
hdc shell aa force-stop <bundle>    # force stop app
```

## File Transfer

```
hdc file send <local> <remote>      # push file
hdc file recv <remote> <local>      # pull file
```

## Logging

```
hdc shell hilog                     # view logs (Ctrl+C to stop)
```

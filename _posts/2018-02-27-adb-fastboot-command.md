---
title: "adb fastboot command"
layout: post
category: android
---

## install recovery

#### [fastboot commands examples](https://android.gadgethacks.com/how-to/complete-guide-flashing-factory-images-android-using-fastboot-0175277/)


#### 确认usb链接上, 我使用的vbox，所以需要usb映射到vm上，vm上确认一下usb映射ok：
 
```
$ lsusb
Bus 001 Device 006: ID 18d1:4ee7 Google Inc. 
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 002 Device 002: ID 80ee:0021 VirtualBox USB Tablet
Bus 002 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
```

映射ok后，就可以用adb和fastboot命令控制手机了

---

#### 重启到bootloader

```
adb reboot adb bootloader
```

#### 安装 recovery

需要最新的recovery才能支持新的rom

```
$ fastboot flash recovery twrp-3.2.1-0-oneplus3.img 
target reported max download size of 440401920 bytes
sending 'recovery' (22680 KB)...
OKAY [  5.982s]
writing 'recovery'...
OKAY [  0.183s]
finished. total time: 6.165s

```

---

## 安装firmware和rom



#### 重启到recovery , 进行双清，（dalvik 和 cache ），并安装fireware和rom。

```
$ adb sideload OnePlus3T_Beta22-\(31-01-18\)-FIRMWARE-flashable.zip 
* daemon not running; starting now at tcp:5037
* daemon started successfully
adb: sideload connection failed: insufficient permissions for device: user in plugdev group; are your udev rules wrong?
See [http://developer.android.com/tools/device.html] for more information
adb: trying pre-KitKat sideload method...
adb: pre-KitKat sideload connection failed: insufficient permissions for device: user in plugdev group; are your udev rules wrong?
See [http://developer.android.com/tools/device.html] for more information
```

```
$ adb sideload lineage-14.1-20180223-nightly-oneplus3-signed.zip
```

---

## [去除网络感叹号方法](https://mr21.cc/geek/remove-the-network-status-notification-in-android-5-6-7-711.html)

这里是让手机不断访问HTTP CODE 204的URL, 默认是google的地址。

#### 重置

```
adb shell "settings delete global captive_portal_server"
adb shell "settings delete global captive_portal_https_url"
adb shell "settings delete global captive_portal_http_url"
adb shell "settings put global captive_portal_detection_enabled 1"
```

#### 修改 

```
adb shell "settings put global captive_portal_https_url https://captive.v2ex.co/generate_204"

```

---

## 解决普通用户使用adb时候出现[insufficient permissions for
device](https://stackoverflow.com/questions/28704636/insufficient-permissions-for-device-in-android-studio-workspace-running-in-opens) 的问题


获取uid信息

```
$ lsusb
Bus 001 Device 002: ID 05c6:9025 Qualcomm, Inc. Qualcomm HSUSB Device
```

添加usb信息到udev中，让挂载的时候属性修改

```
$ cat >> /etc/udev/rules.d/50-android.rules SUBSYSTEM=="usb", ATTR{idVendor}=="05c6", ATTR{idProduct}=="9025",SYMLINK+="android_adb", OWNER="kk"
```

删除 ~/.android/ 信息，删除后手机输入adb
shell的话，手机会提示认证，确定即可从新生成 ***~/.adb/adbkey***

---

## [Refresh Android mediastore using adb](https://stackoverflow.com/questions/17928576/refresh-android-mediastore-using-adb)


not recursive

```
adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///mnt/sdcard/Music/<exact_file_name>
```

recursive

```
adb shell "find /mnt/sdcard/Music/ | while read f; do \
    am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE \
    -d \"file://${f}\"; done"
```

---

## battery

```
adb shell dumpsys battery | grep level
```

---
layout: post
title: "android using adb and fastboot command"
category: android
tags: [android, linux, adb]
---


###  [How to skip WiFi configuration during initial setup of Nexus 7](How to skip WiFi configuration during initial setup of Nexus 7)

```
adb $> mount /system 
adb $> echo "ro.setupwizard.mode=DISABLED" >> /system/build.prop
adb $> sed -i 's/ro.setupwizard.wifi_required=true/ro.setupwizard.wifi_required=false/g' /system/build.prop
```

---

### udev permissions


running ./adb device
I get this error:


```
 List of devices attached 
 ????????????    no permissions
```

解决方法：

+ lsusb
```
Bus 002 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 001 Device 020: ID 18d1:4ee7 Google Inc. 
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
```

+ cat /etc/udev/rules.d/50-android.rules 

```
SUBSYSTEM=="usb", ATTR{idVendor}=="05c6", ATTR{idProduct}=="9025",SYMLINK+="android_adb", OWNER="kk"
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4ee7",SYMLINK+="android_adb", OWNER="kk"
```

+ [udev修改生效](https://unix.stackexchange.com/questions/39370/how-to-reload-udev-rules-without-reboot)

```
sudo sh -c 'udevadm control --reload-rules && udevadm trigger'
```

---

### [recovery](http://www.tttabc.com/android/fastboot.html)

#### [fastboot commands examples](https://android.gadgethacks.com/how-to/complete-guide-flashing-factory-images-android-using-fastboot-0175277/)

```
fastboot flash <partition> [ <filename> ] write a file to a flash partition
```

```
./fastboot flash recovery ~/Downloads/recovery.img
```


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

### [gapps](http://wiki.cyanogenmod.org/w/Google_Apps)

CyanogenMod由于版权问题所以不集成了 ，需要另外安装,记得需要先更新recovery，否则不能成功。 一般在刷rom后马上进行

---

### 刷roms


+ 双清 ***dalvik*** 和  ***cache***
+ 安装firmware


    ```
    $ adb sideload OnePlus3T_Beta22-\(31-01-18\)-FIRMWARE-flashable.zip 
    * daemon not running; starting now at tcp:5037
    * daemon started successfully
    ```

+ 刷rom

    ```
    $ adb sideload lineage-14.1-20180223-nightly-oneplus3-signed.zip
    ```

+ gapps

---

### [去除网络感叹号方法](https://mr21.cc/geek/remove-the-network-status-notification-in-android-5-6-7-711.html)

这里是让手机不断访问HTTP CODE 204的URL, 默认是google的地址。

重置

```
adb shell "settings delete global captive_portal_server"
adb shell "settings delete global captive_portal_https_url"
adb shell "settings delete global captive_portal_http_url"
adb shell "settings put global captive_portal_detection_enabled 1"
```

修改 

```
adb shell "settings put global captive_portal_https_url https://captive.v2ex.co/generate_204"
```

---

### 添加音乐[Refresh Android mediastore using adb](https://stackoverflow.com/questions/17928576/refresh-android-mediastore-using-adb)


not recursive

```
adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///mnt/sdcard/Music/<exact_file_name>
```

recursive

```
for i in `adb shell find /sdcard/Music/` ; do adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file://"$i"; done
```

---

### 显示电池battery

```
adb shell dumpsys battery | grep level
```

---

### [backup apk](https://stackoverflow.com/questions/4032960/how-do-i-get-an-apk-file-from-an-android-device)

```
adb shell pm list packages -f -3
package:/data/app/XX.XX.XX.apk=YY.YY.YY
adb pull /data/app/XX.XX.XX.apk
```


```
$ adb shell pm list packages -f -3 | grep -P "fake|gps|shadowsocks|obfs"
package:/data/app/com.github.shadowsocks-2/base.apk=com.github.shadowsocks
package:/data/app/com.github.shadowsocks.plugin.obfs_local-1/base.apk=com.github.shadowsocks.plugin.obfs_local
package:/data/app/com.lexa.fakegps-1/base.apk=com.lexa.fakegps

$ adb pull /data/app/com.github.shadowsocks-2/base.apk shadowsocks.apk
/data/app/com.github.shadowsocks-2/base.apk: 1 file pulled. 8.2 MB/s (5358433 bytes in 0.625s)
$ adb pull /data/app/com.github.shadowsocks.plugin.obfs_local-1/base.apk obfs.apk
/data/app/com.github.shadowsocks.plugin.obfs_local-1/base.apk: 1 file pulled. 6.9 MB/s (1184779 bytes in 0.163s)
$ adb pull /data/app/com.lexa.fakegps-1/base.apk fakegps.apk
/data/app/com.lexa.fakegps-1/base.apk: 1 file pulled. 7.7 MB/s (1613972 bytes in 0.199s)
```

---
layout: post
title: "android using adb and fastboot command"
category: android
tags: [android, linux, adb]
---

###  install dev-util/android-tools


qlist dev-util/android-tools-8.1.0_p1

```
/usr/lib/python-exec/python3.6/mkbootimg
/usr/lib/python-exec/python2.7/mkbootimg
/usr/share/bash-completion/completions/fastboot
/usr/share/doc/android-tools-8.1.0_p1/README.md.bz2
/usr/share/doc/android-tools-8.1.0_p1/SYNC.TXT.bz2
/usr/share/doc/android-tools-8.1.0_p1/SERVICES.TXT.bz2
/usr/share/doc/android-tools-8.1.0_p1/OVERVIEW.TXT.bz2
/usr/share/doc/android-tools-8.1.0_p1/protocol.txt.bz2
/usr/bin/fastboot
/usr/bin/adb
/usr/bin/mkbootimg
```

equery g dev-util/android-tools-8.1.0_p1

```
 * Searching for android-tools8.1.0_p1 in dev-util ...

 * dependency graph for dev-util/android-tools-8.1.0_p1
 `--  dev-util/android-tools-8.1.0_p1  ~amd64 
   `--  sys-libs/zlib-1.2.11-r2  (sys-libs/zlib) amd64 
   `--  dev-libs/libpcre2-10.30  (dev-libs/libpcre2) amd64 
   `--  virtual/libusb-1-r2  (virtual/libusb) amd64 
   `--  dev-lang/go-1.10.3  (dev-lang/go) amd64 
   `--  dev-util/ninja-1.8.2  (dev-util/ninja) amd64 
   `--  dev-util/cmake-3.9.6  (>=dev-util/cmake-3.9.6) amd64 
   `--  dev-lang/python-2.7.14-r1  (>=dev-lang/python-2.7.5-r2) amd64 
   `--  dev-lang/python-3.4.8  (dev-lang/python) amd64 
   `--  dev-lang/python-3.5.5  (dev-lang/python) amd64 
   `--  dev-lang/python-3.6.5  (dev-lang/python) amd64 
   `--  dev-lang/python-exec-2.4.5  (>=dev-lang/python-exec-2) amd64  [python_targets_python2_7(-)? python_targets_python3_4(-)? python_targets_python3_5(-)? python_targets_python3_6(-)? -python_single_target_python2_7(-) -python_single_target_python3_4(-) -python_single_target_python3_5(-) -python_single_target_python3_6(-)]
[ dev-util/android-tools-8.1.0_p1 stats: packages (12), max depth (1) ]
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


---

### [recovery](http://www.tttabc.com/android/fastboot.html)


```
fastboot flash <partition> [ <filename> ] write a file to a flash partition
```

```
./fastboot flash recovery ~/Downloads/recovery.img
```


---

### gapps 

CyanogenMod由于版权问题所以不集成了
[gapps](http://wiki.cyanogenmod.org/w/Google_Apps)
，需要另外安装,记得需要先更新recovery，否则不能成功。

### [fastboot commands examples](https://android.gadgethacks.com/how-to/complete-guide-flashing-factory-images-android-using-fastboot-0175277/)

---


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



重启到recovery , 进行双清，***dalvik*** 和  ***cache*** 再并安装firmware和rom。
也可以sideload进行：

```
$ adb sideload OnePlus3T_Beta22-\(31-01-18\)-FIRMWARE-flashable.zip 
* daemon not running; starting now at tcp:5037
* daemon started successfully
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

---

###  [How to skip WiFi configuration during initial setup of Nexus 7](How to skip WiFi configuration during initial setup of Nexus 7)

```
adb $> mount /system 
adb $> echo "ro.setupwizard.mode=DISABLED" >> /system/build.prop
adb $> sed -i 's/ro.setupwizard.wifi_required=true/ro.setupwizard.wifi_required=false/g' /system/build.prop
```

---

## Configure the SSH Server

```
# cd /data/ssh
# cp /system/etc/ssh/sshd_config .
# chmod 600 sshd_config
# vim sshd_config 
```

有关密钥，这里一共修改了4个地方,其中 ***PasswordAuthentication*** 和 ***ChallengeResponseAuthentication*** 的原因是禁止[手工输入密码](https://blog.tankywoo.com/linux/2013/09/14/ssh-passwordauthentication-vs-challengeresponseauthentication.html)

***PubkeyAuthentication***的原因是开启rsa认证

```
# diff -u /system/etc/ssh/sshd_config /data/ssh/sshd_config                                            
--- /system/etc/ssh/sshd_config
+++ /data/ssh/sshd_config
@@ -11,6 +11,7 @@
 # default value.
 
 #Port 22
+Port 55022
 #AddressFamily any
 #ListenAddress 0.0.0.0
 #ListenAddress ::
@@ -43,6 +44,7 @@
 
 #RSAAuthentication yes
 #PubkeyAuthentication yes
+PubkeyAuthentication yes
 
 # The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
 # but this is overridden so installations will only check .ssh/authorized_keys
@@ -62,10 +64,13 @@
 
 # To disable tunneled clear text passwords, change to no here!
 #PasswordAuthentication yes
+PasswordAuthentication no
 #PermitEmptyPasswords no
+PermitEmptyPasswords no
 
 # Change to no to disable s/key passwords
 #ChallengeResponseAuthentication yes
+ChallengeResponseAuthentication no
 
 # Kerberos options
 #KerberosAuthentication no
```

---

## Start the SSH Server at Boot Time

```
# mkdir /data/local/userinit.d
# cd /data/local/userinit.d
# cp /system/bin/start-ssh 99sshd
# chmod 755 99sshd
# vim 99sshd 
```


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
adb shell "find /sdcard/Music/ | while read f; do \
    am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE \
    -d \"file://${f}\"; done"
```

---

## battery

```
adb shell dumpsys battery | grep level
```

--- [list / backup apk](https://stackoverflow.com/questions/4032960/how-do-i-get-an-apk-file-from-an-android-device)

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

---  [How to skip WiFi configuration during initial setup of Nexus 7](How to skip WiFi configuration during initial setup of Nexus 7)

```
adb $> mount /system 
adb $> echo "ro.setupwizard.mode=DISABLED" >> /system/build.prop
adb $> sed -i 's/ro.setupwizard.wifi_required=true/ro.setupwizard.wifi_required=false/g' /system/build.prop
```

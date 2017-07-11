---
layout: post
title: "adb xiaomi_2s"
category: android
tags: [xiaomi, android, adb, recovery, fastboot]
---

### Android adb permision error ###

running ./adb device
I get this error:


```
 List of devices attached 
 ????????????    no permissions
```

解决方法：
```
kk@gentoo ~ $ cat /etc/udev/rules.d/50-android.rules 
SUBSYSTEM=="usb", SYSFS{idVendor}=="2717", MODE=="0666", OWNER="kk"
SUBSYSTEM=="usb_device", SYSFS{idVendor}=="2717", MODE=="0666", OWNER="kk"
SUBSYSTEM=="usb", ATTR{idVendor}=="2717", ATTR{idProduct}=="9039", SYMLINK+="android_adb", OWNER="kk"
```



### recovery ###

recovery的使用方法：
```
fastboot flash <partition> [ <filename> ] write a file to a flash partition
```
[recovery](http://www.tttabc.com/android/fastboot.html)


```
./fastboot flash recovery ~/Downloads/recovery.img
```

### adb和驱动 ###

```
kk@gentoo ~ $ lsusb | grep 2717
Bus 001 Device 030: ID 2717:9039  
```

```
kk@gentoo ~ $ cat ~/.android/adb_usb.ini 
0x2717
```

注意可能会出现permission的异常，解决方法看上面。
```
kk@gentoo ~ $ cat /etc/udev/rules.d/50-android.rules 
SUBSYSTEM=="usb", SYSFS{idVendor}=="2717", MODE=="0666"
SUBSYSTEM=="usb_device", SYSFS{idVendor}=="2717", MODE=="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="2717", ATTR{idProduct}=="9039", SYMLINK+="android_adb"
```



### gapps ###

CyanogenMod由于版权问题所以不集成了
[gapps](http://wiki.cyanogenmod.org/w/Google_Apps)
，需要另外安装,记得需要先更新recovery，否则不能成功。



```
18f6dc18f9ded00959ea169936e5478a  cm-10.1-20130824-UNOFFICIAL-aries.zip
在用系统，是CyanogenMod 10.1，android4.22版本。
5f22f046e37038a3856eeb825e73d4ed  gapps-jb-20130812-signed.zip
google apps，需要升级recovery才能安装。
0c462405d488a7a3129870f7da2893d2  miui_MI2_4.3.21_0c462405d4_4.1.zip
是小米2s官方rom。
44bd255a2da0a579445d68b1847f04bd  miui_NativeMI2_QDT14_44bd255a2d_4.1.zip
是小米2s的android原生rom。
f2a393338c35a1c40e93dbc6666fd7f0  recovery_mi2_cofface_V3.2.zip
是小米论坛找到的recovery，可以支持gapps安装。
97e410a17dc76a67c25c444e61923de9  recovery_offical.zip
是小米的官方recovery，但不能选择zip进行安装也不能安装gapps。
```



---
layout: post
title: "linux 64bit using adb"
category: android
tags: [android, linux, adb]
---

没有安装豌豆夹什么的软件，只能自己动手更新手机的hosts啦。所以电脑使用adb + android的wifi adb来控制，之前安装64bit的wheezy后一直不能使用adb，今天终于有时间查找一下：解决方法如下：

***

### debian 

**http://www.circuidipity.com/adb-fastboot-android.html**

<pre lang="bash" line="1" >
dpkg --add-architecture i386
apt-get update ; apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386
</pre>

***

###  gentoo no-multilib

```
app-emulation/emul-linux-x86-baselibs
```

或者

```
dev-util/android-tools
```

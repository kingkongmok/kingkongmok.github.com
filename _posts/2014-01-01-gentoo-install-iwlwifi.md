---
layout: post
title: "gentoo install iwlwifi"
category: linux
tags: [gentoo, wifi, iwlwifi, kernel]
---

##install sys-firmware/iwl6000-ucode
**[ iwl6000 sucess ] ( http://bpaste.net/show/163406/ )**
ucode文件应当是私有的驱动程序，可以安装对应的ucode文件，例如我的无线网卡需要iwl6000。也可以安装sys-kernel/linux-firmware，这个是合集。但注意会互相block。


##update kernel 
**wifi support according [ gentoo wifi howto ]( http://wiki.gentoo.org/wiki/Wifi )**
**[ detail ] (http://bpaste.net/show/163407/)**
这里需要添加wireless的驱动。之前漏了这个步骤只安装ucode是不可以的。

```
kk@gentoo:~$ sudo lspci | grep net -i
00:19.0 Ethernet controller: Intel Corporation 82577LM Gigabit Network Connection (rev 06)
03:00.0 Network controller: Intel Corporation Centrino Advanced-N 6200 (rev 35)
```

---
layout: post
title: "virtualbox"
category: linux
tags: [virtualbox, windows, port, forward]
---

##[教程原文](http://www.linuxjournal.com/content/tech-tip-port-forwarding-virtualbox-vboxmanage)

**The following commands will forward TCP traffic that originates from port 2222 on your host OS to port 22 on your guest OS:**

```
$ VBoxManage setextradata "VM Name Here" \
      "VBoxInternal/Devices/pcnet/0/LUN#0/Config/guestssh/Protocol" TCP

$ VBoxManage setextradata "VM Name Here" \
      "VBoxInternal/Devices/pcnet/0/LUN#0/Config/guestssh/GuestPort" 22


$ VBoxManage setextradata "VM Name Here” \
      "VBoxInternal/Devices/pcnet/0/LUN#0/Config/guestssh/HostPort" 2222
```

##我自己的配置

```
kk@dns:~$ VBoxManage setextradata xp "VBoxInternal/Devices/pcnet/0/LUN#0/Config/guestssh/Protocol" TCP
Sun VirtualBox Command Line Management Interface Version 3.1.6_OSE
(C) 2005-2010 Sun Microsystems, Inc.
All rights reserved.

kk@dns:~$ VBoxManage setextradata xp "VBoxInternal/Devices/pcnet/0/LUN#0/Config/guestssh/GuestPort" 3389
Sun VirtualBox Command Line Management Interface Version 3.1.6_OSE
(C) 2005-2010 Sun Microsystems, Inc.
All rights reserved.

kk@dns:~$ VBoxManage setextradata xp "VBoxInternal/Devices/pcnet/0/LUN#0/Config/guestssh/HostPort" 3389
Sun VirtualBox Command Line Management Interface Version 3.1.6_OSE
(C) 2005-2010 Sun Microsystems, Inc.
All rights reserved.
```


---

## virtualbox-guest-additions


### journalctl -b -u virtualbox-guest-additions

```
-- Logs begin at Mon 2017-11-13 08:36:04 CST, end at Fri 2018-05-04 11:21:05 CST. --
May 04 11:14:48 kenneth systemd[1]: Starting VirtualBox Guest Additions...
May 04 11:14:48 kenneth systemd[1]: Started VirtualBox Guest Additions.
May 04 11:14:48 kenneth vboxguest-service[228]: VBoxService 5.2.10 r121806 (verbosity: 0) linux.amd64 (May  4 2018 11:13:07) release log
May 04 11:14:48 kenneth vboxguest-service[228]: 00:00:00.000088 main     Log opened 2018-05-04T03:14:48.426741000Z
May 04 11:14:48 kenneth vboxguest-service[228]: 00:00:00.013828 main     OS Product: Linux
May 04 11:14:48 kenneth vboxguest-service[228]: 00:00:00.014307 main     OS Release: 4.9.95-gentoo
May 04 11:14:48 kenneth vboxguest-service[228]: 00:00:00.027808 main     OS Version: #1 SMP Fri May 4 09:28:39 CST 2018
May 04 11:14:48 kenneth vboxguest-service[228]: 00:00:00.044893 main     Executable: /usr/sbin/vboxguest-service
May 04 11:14:48 kenneth vboxguest-service[228]: 00:00:00.044896 main     Process ID: 228
May 04 11:14:48 kenneth vboxguest-service[228]: 00:00:00.044897 main     Package type: LINUX_64BITS_GENERIC (OSE)
May 04 11:14:48 kenneth vboxguest-service[228]: 00:00:00.053270 main     5.2.10 r121806 started. Verbose level = 0
May 04 11:14:48 kenneth vboxguest-service[228]: 00:00:00.149165 automount vbsvcAutoMountWorker: Shared folder 'Downloads' was mounted to '/media>
May 04 11:14:48 kenneth vboxguest-service[228]: 00:00:00.274294 automount Error: vbsvcAutoMountWorker: Could not mount shared folder 'Z_DRIVE' t>
```

###  /lib/systemd/system/virtualbox-guest-additions.service 

```
[Unit]
Description=VirtualBox Guest Additions
ConditionVirtualization=oracle
Before=display-manager.service

[Service]
Type=simple
ExecStartPre=/sbin/modprobe vboxguest
ExecStartPre=/sbin/modprobe vboxsf
ExecStart=/usr/sbin/vboxguest-service --foreground
ExecStopPost=/sbin/modprobe -r vboxsf
ExecStopPost=/sbin/modprobe -r vboxguest
PIDFile=/var/run/vboxguest-service.pid

[Install]
WantedBy=multi-user.target

```

### [Module vboxguest and vboxsf missing](https://forums.gentoo.org/viewtopic-t-1038758-start-0.html)


+ Try to **emerge @module-rebuild**.

---

### virtualbox 瘦身


+ 确认vm的分区没有压缩（如果压缩不能用空文件填空间）, 查找有没有**compress=lzo**

```
mount | grep compress

```

+ 对vm进行0文件填充，并删掉、关机。

```
sudo dd if=/dev/zero of=/var/tmp/bigemptyfile bs=4096k
sudo rm -f /var/tmp/bigemptyfile
sudo systemctl poweroff

```


+ 对vdi文件进行压缩

```
VBoxManage modifyhd wini7.vdi compact
```

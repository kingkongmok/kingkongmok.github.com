---
layout: post
title: "Port Forwarding in Virtualbox with VBoxManage, Vbox的端口映射"
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

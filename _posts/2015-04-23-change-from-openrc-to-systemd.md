---
layout: post
title: "从openrc过渡到systemd"
category: linux
tags: [ss-local, dropbox, squid]
---
{% include JB/setup %}

### [安装systemd](https://wiki.gentoo.org/wiki/Systemd)

安装步骤倒是很简单，只需要修改kernel，mtab文件；安装systemd（注意和udev的block），修改grub参数即可。重启后，查pid = 1的进程是否systemd就知道启动结果了。

### [systemd配置](https://wiki.archlinux.org/index.php/Systemd_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)) 

这里稍稍有点复杂，其中的重点是如何配置***[unit file](http://www.freedesktop.org/software/systemd/man/systemd.unit.html)*** ， 我手动安装systemd后发现很多包没配好service文件，需要找，目前如下：

感觉到不同就是原来的系统配置文件在/etc现在变成了/usr/lib/systemd/了，SA所配置的文件从/etc/init.d变成/etc/systemd/了。启动速度有明显加快。然后一些配置例如/etc/init.d, /etc/rc好像用不上了，基本上所有的rc启动脚本需要重新配置，个别还需要修改***unit file***文件来匹配需求。

### [systemd-networkd](https://wiki.archlinux.org/index.php/Systemd-networkd)

如果不想手动启动，则需要服务启动***systemd-networkd.service***和***systemd-resolved.service***。 另外网卡的配置文件可如下：


```
cat /etc/systemd/network/wired.network
[Match]
Name=enp0s3

[Network]
DNS=114.114.114.114

[Address]
Address=10.0.2.15/24

[Route]
Gateway=10.0.2.2
```

#### ss-local.service

```
[Unit]
Description=showdowsocks

[Service]
User=kk
Group=kk
ExecStart=/usr/bin/ss-local -c /etc/shadowsocks.json
RestartSec=5
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

####  squid.service

```
[Unit]
Description=showdowsocks
After=local-fs.target network.target systemd-resolved

[Service]
User=kk
Group=kk
ExecStart=/usr/bin/ss-local -c /etc/shadowsocks.json
RestartSec=5
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

#### dropbox@kk.service

这里需要注意一下，*unitname*@module.service会通过***%I***传参给unit file ，这里需要先启动ss-local，然后通过proxychains来调用dropbox。

```
[Unit]
Description=Dropbox
After=local-fs.target network.target ss-local

[Service]
ExecStart=/usr/bin/proxychains /opt/dropbox/dropboxd
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=always
User=%I

[Install]
WantedBy=multi-user.target
```

### problems

#### CONFIG_FW_LOADER_USER_HELPER

```
$ sudo emerge  systemd
...
...
 * Messages for package sys-apps/systemd-218-r3:

 *   CONFIG_FW_LOADER_USER_HELPER:   should not be set. But it is.
 * Please check to make sure these options are set correctly.
 * Failure to do so may cause unexpected problems.

```

* sudo make menuconfig

```
Symbol: FW_LOADER_USER_HELPER [=y]                                                                                 x  
Type  : boolean                                                                                                    x  
  Defined at drivers/base/Kconfig:151                                                                              x  
  Selected by: FW_LOADER_USER_HELPER_FALLBACK [=n] && FW_LOADER [=y] || DELL_RBU [=m] && X86 [=y] 
```

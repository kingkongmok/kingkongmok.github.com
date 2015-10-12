---
layout: post
title: "systemd sysctl.service failed"
category: linux
tags: [systemd, sysctl]
---
{% include JB/setup %}

### problems: 

```
$ sudo systemctl status systemd-sysctl.servic
...
mar 11 15:37:46 catelyn systemd[1]: systemd-sysctl.service: main process exited, code=exited, status=1/FAILURE
mar 11 15:37:46 catelyn systemd[1]: Failed to start Apply Kernel Variables.
...
```

* 提示sysctl加载的时候出现问题。

### solution

* 应该有个习惯，修改etc文件前应该备份，并将用户修改为自己的用户。

```
$ sudo find /etc/ -type f -iname \*sysctl* ! -uid 0 
/etc/sysctl.conf
```

* 原来是之前测试的时候添加系统参数忘记删除了：

```
$ tail -n 23 /etc/sysctl.conf

# edit by kk
fs.file-max = 5000000
net.core.netdev_max_backlog = 400000
net.core.optmem_max = 10000000
net.core.rmem_default = 10000000
net.core.rmem_max = 10000000
net.core.somaxconn = 100000
net.core.wmem_default = 10000000
net.core.wmem_max = 10000000
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_congestion_control = bic
net.ipv4.tcp_ecn = 0
net.ipv4.tcp_max_syn_backlog = 12000
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_mem = 30000000 30000000 30000000
net.ipv4.tcp_rmem = 30000000 30000000 30000000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_syncookies = 0
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_wmem = 30000000 30000000 30000000 
```

* 修改后正常。

#### fixed

* 删除上面这多余的sysctl后，已经正常：

```
$ sudo systemctl status systemd-sysctl.service
● systemd-sysctl.service - Apply Kernel Variables
   Loaded: loaded (/usr/lib64/systemd/system/systemd-sysctl.service; static; vendor preset: enabled)
   Active: active (exited) since Mon 2015-10-12 16:21:17 CST; 7min ago
     Docs: man:systemd-sysctl.service(8)
           man:sysctl.d(5)
  Process: 1992 ExecStart=/usr/lib/systemd/systemd-sysctl (code=exited, status=0/SUCCESS)
 Main PID: 1992 (code=exited, status=0/SUCCESS)
   CGroup: /system.slice/systemd-sysctl.service

Oct 12 16:21:17 ins14 systemd-sysctl[1992]: Overwriting earlier assignment of kernel/sysrq in file '/usr/lib64/sy...onf'.
Oct 12 16:21:17 ins14 systemd[1]: Started Apply Kernel Variables.
Hint: Some lines were ellipsized, use -l to show in full.
```

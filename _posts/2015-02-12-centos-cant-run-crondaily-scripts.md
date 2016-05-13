---
layout: post
title: "centos的cron.daily bug"
category: linux
tags: [centos, cront]
---

### 问题

今天发现centos没有run-parts cron.daily的快捷方式，

```
$ ls /etc/cron.daily/
00webalizer  0anacron  0logwatch  certwatch  cups  logrotate  makewhatis.cron  mlocate.cron  prelink  rhsmd  rpm  tmpwatch
```

```
$ sudo ls -l /etc/cron.hourly/
total 8
-rwxr-xr-x 1 root root 390 May 13  2011 mcelog.cron
```

```
$ cat /etc/crontab 
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
HOME=/

# run-parts
01 * * * * root run-parts /etc/cron.hourly
02 4 * * * root run-parts /etc/cron.daily
22 4 * * 0 root run-parts /etc/cron.weekly
42 4 1 * * root run-parts /etc/cron.monthly
```

```
$ sudo grep -i anacron -C 5 /var/log/cron | tail
...
Feb 12 04:01:01 crond[17169]: (root) CMD (run-parts /etc/cron.hourly)
Feb 12 04:02:01 crond[17199]: (root) CMD (run-parts /etc/cron.daily)
Feb 12 04:02:01 anacron[17216]: Updated timestamp for job `cron.daily' to 2015-02-12
Feb 12 04:04:01 crond[17647]: (xxx) CMD otherjobs
Feb 12 04:05:01 crond[17800]: (root) CMD (LANG=C LC_ALL=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg --lock-file /var/lock/mrtg/mrtg_l --confcache-file /var/lib/mrtg/mrtg.ok)
...
```

### [老外的解决方法](https://www.centos.org/forums/viewtopic.php?t=2820)

未经测试:

```bash
yum install cronie
service crond start
```

### 自己的解决方法

应该是***0anacron***的问题，但懒得搞，直接***crontab***处理

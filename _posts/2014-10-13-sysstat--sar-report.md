---
layout: post
title: "sysstat & sar report"
category: linux
tags: [log, sar, sysstat]
---

之前系统不能通过sar来看出各个时段的情况，一直比较奇怪，后来找到需要开始运行一段代码来log这些sysstat，如下：

## centos

```bash
kk@ins14 /tmp $ cat /etc/cron.d/sysstat
# run system activity accounting tool every 10 minutes
*/10 * * * * root /usr/lib64/sa/sa1 1 1
# generate a daily summary of process accounting at 23:53
53 23 * * * root /usr/lib64/sa/sa2 -A
```

## gentoo amd64

***/etc/cron.hourly/sysstat***

```
#!/bin/sh
# Run system activity accounting tool every 10 minutes
/usr/lib64/sa/sa1 600 6 &
```

***/etc/cron.daily/sysstat***

```
#!/bin/sh
# Generate a daily summary of process accounting.  Since this will probably
# get kicked off in the morning, it would probably be better to run against
# the previous days data.
/usr/lib64/sa/sa2 -A &
```

## gentoo x86

***/etc/cron.hourly/sysstat***

```
#!/bin/sh
# Run system activity accounting tool every 10 minutes
/usr/lib/sa/sa1 600 6 &
```

***/etc/cron.daily/sysstat***

```
#!/bin/sh
# Generate a daily summary of process accounting.  Since this will probably
# get kicked off in the morning, it would probably be better to run against
# the previous days data.
/usr/lib/sa/sa2 -A &
```

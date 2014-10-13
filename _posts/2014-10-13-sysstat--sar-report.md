---
layout: post
title: "sysstat & sar report"
category: linux
tags: [log, sar, sysstat]
---
{% include JB/setup %}

之前系统不能通过sar来看出各个时段的情况，一直比较奇怪，后来找到需要开始运行一段代码来log这些sysstat，如下：

```bash
kk@ins14 /tmp $ cat /etc/cron.d/sysstat
# run system activity accounting tool every 10 minutes
*/10 * * * * root /usr/lib64/sa/sa1 1 1
# generate a daily summary of process accounting at 23:53
53 23 * * * root /usr/lib64/sa/sa2 -A
```

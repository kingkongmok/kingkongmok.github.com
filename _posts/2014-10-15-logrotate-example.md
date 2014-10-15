---
layout: post
title: "logrotate example"
category: linux
tags: [logrotate, log, tomcat]
---
{% include JB/setup %}

## example

```
/access.*.log {
    size 1
    rotate 48
    compress
    missingok
    copytruncate
    notifempty
    #create 644 mmSdk mmSdk
}
```

## copytruncate
这是两个过程，首选logrotate会先copy一份orig log => log.1， 然后truncate这个 orig log，好处当然就是不需要重启服务，日志可以继续写，坏处就是效率低，因为拷贝时间通常就要很长。

## create
这个给人的感觉就是一个mv过程，会将orig log => log.1， 然后 touch一个 log文件。在测试中tomcat的accesslog不能被create否则会停止log，感觉这样java的机制有点记住inum的样子。

## compress
压缩

## -d
非常有用的一个选项，用来测试，看看到底运行什么

## notifempty
期望解决空文件继续被覆盖的情况

## missingok
next if no exist, no warnning.

## rotate 48
一共会rotate48份。

## crontab

```bash
33 *    * * *   nice /usr/sbin/logrotate -f logrotate.stat_tomcat_7711
48 *    * * *   nice /usr/sbin/logrotate -f logrotate.stat_tomcat_7722
3 * * * *   nice /usr/sbin/logrotate -f logrotate.stat_tomcat_7733
18 *    * * *   nice /usr/sbin/logrotate -f logrotate.stat_tomcat_7744
```

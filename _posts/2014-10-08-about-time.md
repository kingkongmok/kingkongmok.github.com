---
layout: post
title: "about time"
category: linux
tags: [time, find, touch, date]
---
{% include JB/setup %}

有多个时间相关的设置，其中比较常用的是find和date，对于日志应用较多。

`find`的例子, 其中find -mtime +0是昨天以前的文件，不包含昨天。

{% highlight bash %}
kk@ins14 /var/log $ ls -l | sort -k 6 | cat -n
     1  total 16128
     2  drwxrwsr-x 3 portage portage    4096 2014-08-14 15:09 portage
     3  drwxrwx--- 2 root    portage    4096 2014-08-14 15:40 sandbox
     4  drwxr-xr-x 2 mysql   mysql      4096 2014-08-18 21:15 mysql
     5  drwxr-xr-x 2 root    root       4096 2014-08-19 20:53 ConsoleKit
     6  drwxr-xr-x 2 root    root       4096 2014-08-19 21:10 samba
     7  drwx------ 2 nginx   nginx      4096 2014-08-28 12:49 nginx
     8  -rw-r--r-- 1 root    root     322727 2014-08-31 21:06 genkernel.log
     9  -rw------- 1 root    root        337 2014-09-10 10:03 ppp-connect-errors
    10  drwxr-xr-x 2 root    root       4096 2014-09-10 15:52 iptraf-ng
    11  -rw-r----- 1 root    adm      201237 2014-09-13 15:32 mail.err
    12  drwxr-xr-x 2 root    root       4096 2014-09-15 09:45 cups
    13  drwxr-xr-x 2 tomcat  tomcat     4096 2014-09-30 11:05 tomcat-7
    14  drwxr-xr-x 2 root    root       4096 2014-10-01 08:52 sa
    15  drwxr-x--- 2 squid   squid      4096 2014-10-02 18:07 squid
    16  -rw-r----- 1 root    adm      613125 2014-10-04 00:14 mail.info
    17  -rw-r----- 1 root    adm      613125 2014-10-04 00:14 mail.log
    18  -rw-r----- 1 root    adm      577554 2014-10-04 00:14 mail.warn
    19  -rw-r----- 1 root    adm      574235 2014-10-05 22:58 debug
    20  -rw-r----- 1 root    adm     4627369 2014-10-05 22:58 syslog
    21  -rw-rw---- 1 portage portage    7440 2014-10-06 23:52 emerge-fetch.log
    22  -rw-r----- 1 root    adm        3161 2014-10-07 21:52 user.log
    23  -rw-r----- 1 root    root      25686 2014-10-08 08:53 dmesg
    24  -rw-r--r-- 1 root    root     187877 2014-10-08 08:53 rc.log
    25  -rw-rw---- 1 portage portage  355270 2014-10-08 09:04 emerge.log
    26  -rw-r----- 1 root    adm     1655457 2014-10-08 11:23 kern.log
    27  -rw-r----- 1 root    adm     1338477 2014-10-08 11:23 messages
    28  -rw-r----- 1 root    adm     2464371 2014-10-08 13:34 daemon.log
    29  -rw-r--r-- 1 root    adm       86498 2014-10-08 13:34 debug.log
    30  -rw-r--r-- 1 root    root     292292 2014-10-08 13:38 lastlog
    31  -rw------- 1 root    root      64064 2014-10-08 13:38 tallylog
    32  -rw-rw-r-- 1 root    utmp    1383552 2014-10-08 13:38 wtmp
    33  -rw-r----- 1 root    adm     1272192 2014-10-08 13:40 auth.log
    34  -rw-r--r-- 1 root    adm        8800 2014-10-08 13:40 cron.log
kk@ins14 /var/log $ ls -l | sort -k 6 | cat -n^C
kk@ins14 /var/log $ find -maxdepth 1 -type f -mtime +0 | xargs ls --time-style=long-iso -l  | sort -k 6 | cat -n
     1  -rw-r--r-- 1 root    root          0 2014-08-14 14:21 ./.keep
     2  -rw-r--r-- 1 root    root     322727 2014-08-31 21:06 ./genkernel.log
     3  -rw------- 1 root    root        337 2014-09-10 10:03 ./ppp-connect-errors
     4  -rw-r----- 1 root    adm      201237 2014-09-13 15:32 ./mail.err
     5  -rw-r----- 1 root    adm      613125 2014-10-04 00:14 ./mail.info
     6  -rw-r----- 1 root    adm      613125 2014-10-04 00:14 ./mail.log
     7  -rw-r----- 1 root    adm      577554 2014-10-04 00:14 ./mail.warn
     8  -rw-r----- 1 root    adm      574235 2014-10-05 22:58 ./debug
     9  -rw-r----- 1 root    adm     4627369 2014-10-05 22:58 ./syslog
    10  -rw-rw---- 1 portage portage    7440 2014-10-06 23:52 ./emerge-fetch.log
{% endhighlight %}


`date`的例子
{% highlight bash %}
kk@ins14 /var/log $ date
Wed Oct  8 13:46:45 CST 2014
kk@ins14 /var/log $ date -d -1day
Tue Oct  7 13:46:52 CST 2014
kk@ins14 /var/log $ date -d 1day
Thu Oct  9 13:46:55 CST 2014
kk@ins14 /var/log $ date -d 3week
Wed Oct 29 13:47:02 CST 2014
{% endhighlight %}

`touch`的例子
{% highlight bash %}
kk@ins14 /tmp/Pictures $ ls -l Misa\ Campo\ 1\ 1280x1024\ Sexy\ Wallpaper.jpg.gz
-rw-r--r-- 1 kk kk 344510 2013-11-11 11:11 Misa Campo 1 1280x1024 Sexy Wallpaper.jpg.gz
kk@ins14 /tmp/Pictures $ stat Misa\ Campo\ 1\ 1280x1024\ Sexy\ Wallpaper.jpg.gz
  File: ‘Misa Campo 1 1280x1024 Sexy Wallpaper.jpg.gz’
  Size: 344510      Blocks: 680        IO Block: 4096   regular file
Device: 801h/2049d  Inode: 935505      Links: 1
Access: (0644/-rw-r--r--)  Uid: ( 1000/      kk)   Gid: ( 1000/      kk)
Access: 2013-11-11 11:11:11.000000000 +0800
Modify: 2013-11-11 11:11:11.000000000 +0800
Change: 2014-10-08 13:37:41.620258450 +0800
 Birth: -
{% endhighlight %}



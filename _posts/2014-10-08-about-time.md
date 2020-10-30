---
layout: post
title: "date and time"
category: linux
tags: [time, find, touch, date]
---

有多个时间相关的设置，其中比较常用的是find和date，对于日志应用较多。

## `find`的例子
 其中find -mtime +0是昨天以前的文件，不包含昨天。

```
       -atime n
              File  was  last accessed n*24 hours ago.  When find figures out how many 24-hour periods ago the
              file was last accessed, any fractional part is ignored, so to match -atime +1,  a  file  has  to
              have been accessed at least two days ago.
```

```bash
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
```


## `date`的例子

```bash
$ date
Wed Oct  8 13:46:45 CST 2014

$ date -d -1day
Tue Oct  7 13:46:52 CST 2014

$ date -d 1day
Thu Oct  9 13:46:55 CST 2014

$ date -d 3week
Wed Oct 29 13:47:02 CST 2014

$ date -d @1315167865
Mon Sep  5 04:24:25 CST 2011

$ date +%s
1415168070
```

## `touch`的例子

```bash
kk@ins14 /tmp $ ls -l hp1000_linux.txt 
-rw-r--r-- 1 kk kk 1223 2014-10-13 09:25 hp1000_linux.txt
kk@ins14 /tmp $ touch -t 11111111.11 hp1000_linux.txt 
kk@ins14 /tmp $ ls -l hp1000_linux.txt 
-rw-r--r-- 1 kk kk 1223 2014-11-11 11:11 hp1000_linux.txt
kk@ins14 /tmp $ touch -t 201111111111.11 hp1000_linux.txt 
kk@ins14 /tmp $ ls -l hp1000_linux.txt 
-rw-r--r-- 1 kk kk 1223 2011-11-11 11:11 hp1000_linux.txt
```

 man一下touch的用法可以知道
 
```
       -t STAMP
              use [[CC]YY]MMDDhhmm[.ss] instead of current time
```

### perl


* nginx的log如下：

```
127.0.0.1 - - [12/Nov/2014:15:47:20 +0800] "GET / HTTP/1.1" 200 1449 "-" "curl/7.39.0" "-"
127.0.0.1 - - [12/Nov/2014:15:47:20 +0800] "GET / HTTP/1.1" 200 1449 "-" "curl/7.39.0" "-"
127.0.0.1 - - [12/Nov/2014:15:47:20 +0800] "GET / HTTP/1.1" 200 1449 "-" "curl/7.39.0" "-"
127.0.0.1 - - [12/Nov/2014:15:47:20 +0800] "GET / HTTP/1.1" 200 1449 "-" "curl/7.39.0" "-"
127.0.0.1 - - [12/Nov/2014:15:47:20 +0800] "GET / HTTP/1.1" 200 1449 "-" "curl/7.39.0" "-"
127.0.0.1 - - [12/Nov/2014:15:47:20 +0800] "GET / HTTP/1.1" 200 1449 "-" "curl/7.39.0" "-"
127.0.0.1 - - [12/Nov/2014:15:47:20 +0800] "GET / HTTP/1.1" 200 1449 "-" "curl/7.39.0" "-"
```


```
perl -MPOSIX -nE 'BEGIN{$l=strftime "%T",localtime time - 3600 }  if (/:(\S+?)\s/){print if $l lt $1}' /nginx/access.log
```

```
$ perl -MPOSIX -MDate::Parse -E 'say strftime "%F %T", localtime str2time"12/Nov/2014:15:47:20 +0800"'
2014-11-12 15:47:20
```

* emerge.log


```
$ sudo grep docker /var/log/emerge.log | perl -MPOSIX -npE 's/^\d+/strftime"%F_%T",localtime $&/e'
```

```
2019-03-30_00:05:48:  >>> unmerge success: app-emulation/docker-proxy-0.8.0_p20181207
2019-03-30_00:05:50:  === (1 of 6) Post-Build Cleaning (app-emulation/docker-proxy-0.8.0_p20190301::/usr/portage/app-emulation/docker-proxy/docker-proxy-0.8.0_p20190301.ebuild)
2019-03-30_00:05:50:  ::: completed emerge (1 of 6) app-emulation/docker-proxy-0.8.0_p20190301 to /
2019-03-30_00:11:38:  >>> emerge (6 of 6) app-emulation/docker-18.09.4 to /
2019-03-30_00:11:38:  === (6 of 6) Cleaning (app-emulation/docker-18.09.4::/usr/portage/app-emulation/docker/docker-18.09.4.ebuild)
2019-03-30_00:11:38:  === (6 of 6) Compiling/Merging (app-emulation/docker-18.09.4::/usr/portage/app-emulation/docker/docker-18.09.4.ebuild)
```

---

linux date command

```
# Get the seconds since epoch
date -d "Oct 21 1973" +%s

#Convert the number of seconds back to string
date -d @120024000
```

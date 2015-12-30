---
layout: post
title: "io speed test"
category: linux
tags: [io, dd, hdparm]
---
{% include JB/setup %}

### 读的速度测试

1. 文件系统

    ```
    # /sbin/hdparm -Tt /dev/mpath/36005076304ffd0980000000000005309 

    /dev/mpath/36005076304ffd0980000000000005309: 
    Timing cached reads: 24460 MB in 2.00 seconds = 12257.65 MB/sec 
    Timing buffered disk reads: 326 MB in 3.01 seconds = 108.17 MB/sec 
    ```
    * 注意`hdparm -Tt`只会分析其他进程对block的请求，不会主动产生io；
    * 当然是buffered才有分析价值。

2. 网络挂载

    ```
    rsync -avih /mnt/nfs/memcached-1.2.8-repcached-2.2.1.tar.gz .
    >f+++++++++ memcached-1.2.8-repcached-2.2.1.tar.gz

    sent 30 bytes  received 228.73K bytes  91.50K bytes/sec
    total size is 228.58K  speedup is 1.00
    ```

---

### 写速度

1. dd

    ```
     sudo dd if=/dev/zero of=~/testfile bs=1024 count=10240
     10240+0 records in
     10240+0 records out
     10485760 bytes (10 MB) copied, 0.0591223 s, 177 MB/s
    ```

---

### 读写分析

1. sar

    ```
    $ sar -b
    Linux 4.1.12-gentoo (ins14)     12/30/2015  _x86_64_    (1 CPU)

    09:08:22 AM       LINUX RESTART (1 CPU)

    09:10:01 AM       tps      rtps      wtps   bread/s   bwrtn/s
    09:20:01 AM     15.39      2.18     13.20    109.72    416.11
    09:30:01 AM     17.62      4.96     12.66    158.91    394.49
    09:40:01 AM     74.08     61.08     13.00   1150.04    475.35
    ```

2. iotop

    ```
    $ sudo iotop  -bn1 | head -20
    Total DISK READ :       0.00 B/s | Total DISK WRITE :       4.84 M/s
    Actual DISK READ:       0.00 B/s | Actual DISK WRITE:       0.00 B/s
      TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN      IO    COMMAND
    23996 be/4 root        0.00 B/s    4.84 M/s  0.00 % 77.00 % dd if=/dev/zero of=/home/kk/testfile bs=1024 count=10240000
     2688 be/4 zabbix      0.00 B/s    0.00 B/s  0.00 % 27.05 % zabbix_server: proxy poller #1 [exchanged data with 0 proxies in 0.003539 sec, idle 5 sec]
        1 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % systemd
        2 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [kthreadd]
        3 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [ksoftirqd/0]
        5 be/0 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [kworker/0:0H]
    ```
    * ps iotop 依赖python和python-exec2



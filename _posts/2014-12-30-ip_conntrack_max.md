---
layout: post
title: "ip_conntrack_max和多连接"
category: linux
tags: [sysctl, nginx]
---
{% include JB/setup %}

今天发现新配置的服务器上出现了奇怪的表现

### nginx error log 

```
2014/12/30 15:03:55 [error] 12695#0: *1678885 upstream timed out (110: Connection timed out) while connecting to upstream, client:
```


查找原因：

### dmesg error log

```
ip_conntrack: table full, dropping packet
```

[问题原因](https://major.io/2008/01/24/ip_conntrack-table-full-dropping-packet/)

### 临时解决方法

```
echo '262144' > /proc/sys/net/ipv4/ip_conntrack_max
```

###  其他问题

```
TCP: time wait bucket table overflow
```

```
 $ sudo /sbin/sysctl -a | grep net.ipv4.tcp_fin_timeout
 net.ipv4.tcp_fin_timeout = 15
```

### 临时处理方法

[处理方法](http://serverfault.com/questions/449744/a-lot-of-tcp-time-wait-bucket-table-overflow-in-centos-6), 按建议不处理。

---
layout: post
title: "多连接"
category: linux
tags: [sysctl, nginx, dmesg, nginx]
---
{% include JB/setup %}

### 架构 F5 -> ( bond0 -> Nginx -> lo ->  tomcats ) x4


目前的LB配额需要在F5上定制，修改的审批手续比较麻烦。
今天发现新配置的服务器5上出现了奇怪的表现

#### nginx error log 

```
2014/12/30 15:03:55 [error] 12695#0: *1678885 upstream timed out (110: Connection timed out) while connecting to upstream, client:
```


查找原因：

#### dmesg error log

dmesg出现大量提示：

```
ip_conntrack: table full, dropping packet
```

rc.loca加载了以下字段，但/proc/sys/net/ipv4/ip_conntrack_max不知何缘故被重载了，数字不符。

```
ulimit -SHn 131070
modprobe ip_conntrack
echo '262144' > /proc/sys/net/ipv4/ip_conntrack_max
```

[问题原因](https://major.io/2008/01/24/ip_conntrack-table-full-dropping-packet/), 由于服务器在之前已经加载了ip_conntrack模块，并启用了ip_nat和iptable_nat，所以导致不能卸载ip_conntrack的模块。

#### 临时解决方法

```
echo '262144' > /proc/sys/net/ipv4/ip_conntrack_max
```

#### 处理方法

* 关闭ip_conntrack，ip_nat和iptable_nat；
* 由于不熟悉该业务，所以无法判断能否关闭ip_conntrack，ip_nat和iptable_nat；

#### 临时处理方法

* [建议](http://serverfault.com/questions/449744/a-lot-of-tcp-time-wait-bucket-table-overflow-in-centos-6), 按建议不处理。


### 临时架构1 F5 -> ( bond0 -> nginx -> bond0 -> tomcat ) x4

* [参考](https://t37.net/nginx-optimization-understanding-sendfile-tcp_nodelay-and-tcp_nopush.html)
* 得知我们架构的nginx只是proxy架构，和内核<->io使用无关系，所以应当停止使用sendfile和nopush，改用nodelay。
* 文件服务器或者css，jpg等静态页可以使用sendfile， 这里不适合。 
* 业务量大可以使用nopush， 这里不适合。

```
#sendfile        on; 
#tcp_nopush     on;
tcp_nodelay     on;
```

#### 内部访问缓慢，出现丢包 

* 内部网络间访问缓慢，判断为交换机带宽不足或服务器间的tcp资源耗尽；

#### 临时解决方法

还原


### 临时架构2 F5 -> ( bond0 -> nginx -> bond0 -> tomcat ) x4  and  tcp fixed

在调整架构1的情况下，调整内核参数以修改fin2的数量，

#### 修改条目

有建议修改以下项,  参考[这里](http://blog.chinaunix.net/uid-10915175-id-3589455.html)修改
关于[tcp time wait](http://vincent.bernat.im/en/blog/2014-tcp-time-wait-state-linux.html)的简单描述，特别留意下net.ipv4.tcp_tw_reuse和net.ipv4.tcp_tw_recycle的使用

```
net.ipv4.tcp_fin_timeout = 3
net.ipv4.tcp_keepalive_time = 10
net.ipv4.ip_local_port_range = 1024  65535
net.ipv4.tcp_tw_reuse = 1
net.ipv4.conf.default.rp_filter = 0
net.ipv4.tcp_max_tw_buckets = 100
```

#### 修改前

* timeout 和 fin2 很大，负载约3.6 ；

```
          'SYN-SENT' => 8,
          'ESTAB' => 2373,
          'State' => 1,
          'FIN-WAIT-1' => 10,
          'LAST-ACK' => 1,
          'FIN-WAIT-2' => 1207,
          'TIME-WAIT' => 59157,
          'SYN-RECV' => 402,
          'LISTEN' => 24
```

#### 修改后

* 修改后，改善了fin的值和timewait的值,负载约2.8

```
          'CLOSING' => 1,
          'SYN-SENT' => 7,
          'ESTAB' => 1463,
          'State' => 1,
          'FIN-WAIT-1' => 45,
          'FIN-WAIT-2' => 895,
          'TIME-WAIT' => 103,
          'SYN-RECV' => 386,
          'LISTEN' => 24
```

#### 存在问题

出现dmesg报错

```
$ sudo dmesg -c
printk: 17661 messages suppressed.
TCP: time wait bucket table overflow
printk: 17931 messages suppressed.
TCP: time wait bucket table overflow
```

### 抓包

应当确定相应网卡端口间的数据是否正确，并确认内网间使用http1.1 keepalive（没有 S S. F.）的存在。

```
sudo /usr/sbin/tcpdump -n -i bond0 tcp port xxxx
```

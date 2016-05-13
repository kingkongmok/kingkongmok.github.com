---
layout: post
title: "iptables 和 ip_conntrack"
category: linux
tags: [iptalbes, nf_conntrack, ip_conntrack]
---

### ip_conntrack 和 nf_conntrack

[引用](http://blog.csdn.net/lucky_greenegg/article/details/43192333)

* nf_conntrack 工作在 3 层，支持 IPv4 和 IPv6，而 ip_conntrack 只支持 IPv4。目前，大多的 ip_conntrack 已被 nf_conntrack 取代，很多 ip_conntrack 仅仅是个 alias，原先的 ip_conntrack 的 /proc/sys/net/ipv4/netfilter/ 依然存在，但是新的 nf_conntrack 在 /proc/sys/net/netfilter/ 中，这个应该是做个向下的兼容：
* nf_conntrack/ip_conntrack 跟 nat 有关，用来跟踪连接条目，它会使用一个哈希表来记录 established 的记录。nf_conntrack 在 2.6.15 被引入，而 ip_conntrack 在 2.6.22 被移除，如果该哈希表满了，就会出现：

```
nf_conntrack: table full, dropping packet
```

###  [引用](http://blog.csdn.net/lucky_greenegg/article/details/43192333) 解决丢包的iptable写法 （ 未经过验证 ）

```
iptables -A FORWARD -m state --state UNTRACKED -j ACCEPT
iptables -t raw -A PREROUTING -p tcp -m multiport --dport 9001,9000,9002 -j NOTRACK
iptables -t raw -A PREROUTING -p tcp -m multiport --sport 9001,9000,9002 -j NOTRACK
```



### ip_conntrack 和 iptable_filter 等模块

在redhat系列中，iptables内核支持功能以模块形式被编译，并可通过rc/systemd来添加删除这些模块。而在其他的发行版中，有可能直接写入内核不支持模块需要注意。


```
lsmod  | grep -P "ip_conntrack|iptable_filter"
ip_conntrack_netbios_ns    36033  0 
ip_conntrack           92005  2 ip_conntrack_netbios_ns,xt_state
nfnetlink              40585  1 ip_conntrack
iptable_filter         36161  1 
ip_tables              55457  1 iptable_filter
```

例如某Debian8的VPS中，lsmod并没有相关的模块：

```
lsmod  | grep -P "ip_conntrack|iptable_filter"
```

### ip_conntrack 的相关设置

* ip_conntrack_max

    这个用于增加ip_conntrack的条数，见/proc/sys/net/ipv4/ip_conntrack_max

* ip_conntrack_tcp_timeout_established
    
    这个可以修改时限 默认5天即432000s

* ip_conntrack hashsize

    这个和hash文件的大小有关，但未找到相应proc位置。更多的内容可以找/proc/sys/net/ipv4/netfilter

### slabtop 和 /proc/slabinfo

*    这里可以查找到相关ip_conntrack所占用的cached情况。

```
# grep conntrack /proc/slabinfo
    ip_conntrack       38358  64324    304   13    1 : tunables   54   27    8 : slabdata   4948   4948    216
```

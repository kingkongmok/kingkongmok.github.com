---
layout: post
title: "ip_conntrack"
category: linux
tags: [iptalbes]
---
{% include JB/setup %}

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

    这里可以查找到相关ip_conntrack所占用的cached情况。

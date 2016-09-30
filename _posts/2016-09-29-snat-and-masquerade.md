---
title: "SNAT and masquerade"
layout: post
category: linux
---

### [Difference between SNAT and Masquerade](http://unix.stackexchange.com/questions/21967gg/difference-between-snat-and-masquerade)


The **SNAT** target requires you to give it an IP address to apply to all the outgoing packets. The **MASQUERADE** target lets you give it an interface, and whatever address is on that interface is the address that is applied to all the outgoing packets. In addition, with **SNAT**, the kernel's connection tracking keeps track of all the connections when the interface is taken down and brought back up; the same is not true for the **MASQUERADE** target.

Good documents include the HOWTOs on the Netfilter site and the iptables [man page](http://linux.die.net/man/8/iptables).

#### SNAT作用于IP
#### Masquerade作用于接口

---

### DNAT and SNAT

SNAT是指在数据包从网卡发送出去的时候，把数据包中的源地址部分替换为指定的IP，这样，接收方就认为数据包的来源是被替换的那个IP的主机
DNAT，就是指数据包从网卡发送出去的时候，修改数据包中的目的IP，表现为如果你想访问A，可是因为网关做了DNAT，把所有访问A的数据包的目的IP全部修改为B，那么，你实际上访问的是B

因为，路由是按照目的地址来选择的，因此，DNAT是在PREROUTING链上来进行的，而SNAT是在数据包发送出去的时候才进行，因此是在POSTROUTING链上进行的

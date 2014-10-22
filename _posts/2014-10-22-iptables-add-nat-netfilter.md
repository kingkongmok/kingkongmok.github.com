---
layout: post
title: "iptables add nat netfilter"
category: linux
tags: [iptables, nat, kernel]
---
{% include JB/setup %}

在新增一条nat的iptable配置时候出现问题：

```bash
kk@ins14 /usr/src/linux $ sudo iptables -t nat -A PREROUTING -d 10.0.2.15 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 8080
iptables v1.4.21: can't initialize iptables table `nat': Table does not exist (do you need to insmod?)
Perhaps iptables or your kernel needs to be upgraded.
```

查找[解决方法](https://forums.gentoo.org/viewtopic-t-718964-start-0.html),帖子中需要的是***CONFIG_NF_CONNTRACK CONFIG_NF_CONNTRACK_IPV4  CONFIG_NF_NAT***

我自己的情况需要新添加***CONFIG_NF_NAT_IPV4***和***CONFIG_NF_NAT_IPV6***依然出错

最后是添加以下两个并重新编译内核后成功，不清楚到底是内核问题还是模块问题，一般来说编译上面应该就可以了.
***CONFIG_NF_TABLES CONFIG_IP_SET***


```bash
kk@ins14 /usr/src/linux $ diff .config .config--2014-08-31--20-11-35.bak 
752,774c752
< CONFIG_NF_NAT=m
< CONFIG_NF_NAT_NEEDED=y
< CONFIG_NF_NAT_PROTO_UDPLITE=m
< CONFIG_NF_NAT_PROTO_SCTP=m
< CONFIG_NF_NAT_AMANDA=m
< CONFIG_NF_NAT_FTP=m
< CONFIG_NF_NAT_IRC=m
< CONFIG_NF_NAT_SIP=m
< CONFIG_NF_NAT_TFTP=m
< CONFIG_NF_TABLES=m
< # CONFIG_NF_TABLES_INET is not set
< # CONFIG_NFT_EXTHDR is not set
< # CONFIG_NFT_META is not set
< # CONFIG_NFT_CT is not set
< # CONFIG_NFT_RBTREE is not set
< # CONFIG_NFT_HASH is not set
< # CONFIG_NFT_COUNTER is not set
< # CONFIG_NFT_LOG is not set
< # CONFIG_NFT_LIMIT is not set
< # CONFIG_NFT_NAT is not set
< # CONFIG_NFT_QUEUE is not set
< # CONFIG_NFT_REJECT is not set
< # CONFIG_NFT_COMPAT is not set
---
> # CONFIG_NF_TABLES is not set
782d759
< # CONFIG_NETFILTER_XT_SET is not set
800d776
< CONFIG_NETFILTER_XT_TARGET_NETMAP=m
805d780
< CONFIG_NETFILTER_XT_TARGET_REDIRECT=m
861,875c836
< CONFIG_IP_SET=m
< CONFIG_IP_SET_MAX=256
< # CONFIG_IP_SET_BITMAP_IP is not set
< # CONFIG_IP_SET_BITMAP_IPMAC is not set
< # CONFIG_IP_SET_BITMAP_PORT is not set
< # CONFIG_IP_SET_HASH_IP is not set
< # CONFIG_IP_SET_HASH_IPPORT is not set
< # CONFIG_IP_SET_HASH_IPPORTIP is not set
< # CONFIG_IP_SET_HASH_IPPORTNET is not set
< # CONFIG_IP_SET_HASH_NETPORTNET is not set
< # CONFIG_IP_SET_HASH_NET is not set
< # CONFIG_IP_SET_HASH_NETNET is not set
< # CONFIG_IP_SET_HASH_NETPORT is not set
< # CONFIG_IP_SET_HASH_NETIFACE is not set
< # CONFIG_IP_SET_LIST_SET is not set
---
> # CONFIG_IP_SET is not set
884,885d844
< # CONFIG_NF_TABLES_IPV4 is not set
< # CONFIG_NF_TABLES_ARP is not set
895,901c854
< CONFIG_NF_NAT_IPV4=m
< CONFIG_IP_NF_TARGET_MASQUERADE=m
< CONFIG_IP_NF_TARGET_NETMAP=m
< CONFIG_IP_NF_TARGET_REDIRECT=m
< CONFIG_NF_NAT_PROTO_GRE=m
< CONFIG_NF_NAT_PPTP=m
< CONFIG_NF_NAT_H323=m
---
> # CONFIG_NF_NAT_IPV4 is not set
916d868
< # CONFIG_NF_TABLES_IPV6 is not set
933,936c885
< CONFIG_NF_NAT_IPV6=m
< CONFIG_IP6_NF_TARGET_MASQUERADE=m
< CONFIG_IP6_NF_TARGET_NPT=m
< # CONFIG_NF_TABLES_BRIDGE is not set
---
> # CONFIG_NF_NAT_IPV6 is not set
1028d976
< # CONFIG_NET_EMATCH_IPSET is not set
4094,4096c4042,4044
< CONFIG_CRYPTO_SHA1_SSSE3=m
< CONFIG_CRYPTO_SHA256_SSSE3=m
< CONFIG_CRYPTO_SHA512_SSSE3=m
---
> # CONFIG_CRYPTO_SHA1_SSSE3 is not set
> # CONFIG_CRYPTO_SHA256_SSSE3 is not set
> # CONFIG_CRYPTO_SHA512_SSSE3 is not set
```

这次正常。

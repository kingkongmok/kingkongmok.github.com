---
layout: post
title: "keepalived and vrrp"
category: linux
tags: [keepalived, vrrp, linux]
---

其实如果只有10多台服务器的话，没必要使用3/4层交换的ipvs
技术，直接使用7层的nginx的upstream较好。

<pre lang="bash" line="1">
! Configuration File for keepalived

global_defs {
   notification_email {
     acassen@firewall.loc
     failover@firewall.loc
     sysadmin@firewall.loc
   }
   notification_email_from Alexandre.Cassen@firewall.loc
   smtp_server 192.168.200.1
   smtp_connect_timeout 30
   router_id LVS_DEVEL
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 100
    virtual_ipaddress {
        192.168.1.1
    }
}
</pre>

**http://www.ultramonkey.org/papers/lvs_tutorial/html/**

##服务端设置 192.1.6.1/24

<pre lang="bash" >
root@c0:~# echo 1 > /proc/sys/net/ipv4/ip_forward
root@c0:~# ipvsadm -A -t 192.1.6.10:80 -s rr
root@c0:~# ipvsadm -a -t 192.1.6.10:80 -r 192.1.6.1 -g
root@c0:~# ipvsadm -a -t 192.1.6.10:80 -r 192.1.6.2 -g
root@c0:~# ipvsadm -ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  192.1.6.10:80 rr
  -> 192.1.6.1:80                 Local   1      0          0         
  -> 192.1.6.2:80                 Route   1      0          0     
root@c0:~# ifconfig eth0:0 192.1.6.10/24 up
root@c0:~# route add -host 192.1.6.10 dev eth0:0
</pre>

**http://www.ultramonkey.org/papers/lvs_tutorial/html/**

##客户端端设置 192.1.6.2/24

<pre lang="bash" >
root@c1:~# echo 1 > /proc/sys/net/ipv4/conf/lo/arp_ignore
root@c1:~# echo 1 > /proc/sys/net/ipv4/conf/eth0/arp_ignore
root@c1:~# echo 2 > /proc/sys/net/ipv4/conf/lo/arp_announce
root@c1:~# echo 2 > /proc/sys/net/ipv4/conf/eth0/arp_announce
root@c1:~# ifconfig lo:0 192.1.6.10 netmask 255.255.255.255 up
root@c1:~# route add -host 192.1.6.10 dev lo:0
</pre>

**http://www.ultramonkey.org/papers/lvs_tutorial/html/**

#debug

<pre lang="bash" >
root@c1:~# tcpdump -n -i any port 80
</pre>

---
layout: post
title: "keepalive at home's pc"
category: linux
tags: [port, forward, linux, keepalived, home]
---
{% include JB/setup %}

##keepalived就是电脑使用vrrpd
家里添加一台笔记本后，台式电脑的运行时间就少了。但是不能让白白运行啊，要善于下载！所以mldonkey也拷贝到笔记本上了。
但是之前的port forward做在了台式机上了，没有port forward当然下载会慢，所以用keepalived的方法来解决。让台式机和笔记本共用一个virtual ip。

##安装方法

```sh
sudo apt-get install keepalived
sudo cp /usr/share/doc/keepalived/samples/keepalived.conf.sample /etc/keepalived/keepalived.conf
```

**priority 99 for laptop**

{% highlight bash %}
! Configuration File for keepalived

global_defs {
   notification_email {
     acassen
   }
   notification_email_from Alexandre.Cassen@firewall.loc
   smtp_server localhost
   smtp_connect_timeout 30
   router_id LVS_DEVEL
}

vrrp_instance VI_1 {
    interface wlan0
    virtual_router_id 50
    nopreempt
    priority 99
    advert_int 1
    virtual_ipaddress {
        192.168.1.254
    }
}
{% endhighlight %}

**台式机上使用的是100**

##查看

**除了syslog外，可以使用ip a来查看**

```sh
kk@t510:~$ sudo ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether f0:de:f1:51:c6:d4 brd ff:ff:ff:ff:ff:ff
3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
    link/ether 18:3d:a2:2b:11:10 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.51/24 brd 192.168.1.255 scope global wlan0
    inet 192.168.1.254/32 scope global wlan0
    inet6 fe80::1a3d:a2ff:fe2b:1110/64 scope link 
       valid_lft forever preferred_lft forever
```



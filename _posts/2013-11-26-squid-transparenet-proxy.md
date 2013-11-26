---
layout: post
title: "squid transparenet proxy"
category: linux
tags: [squid, proxy, transparenet]
---
{% include JB/setup %}

##只有一个网卡
**公司的文件服务器只有一个网卡，但考虑网络经常出现瓶颈。所以搭建代理服务器，顺便把透明代理设置好。**

<pre lang="bash" line="1">
kk@fileserver:~$ cat /etc/debian_version
7.1
</pre>

由于设置透明代理，需要在http_port中设定类型为"transparenet"，否则会有类似的提示
<pre lang="bash" line="1">
HTTP/1.0 400 Bad Request
Content-Type: text/html 
X-Squid-Error: ERR_INVALID_REQ 0
</pre>

squid的设置一般不需过多修改，比较重要的是cache_dir，这个参数决定了squid的cache目录空间，一般越大
越好。
http_port 后面加上transparent，则能支持透明代理，而且是无需在客户端做过多设置的。
google上还有需设置为cache_peer localhost 等设置，但我这里不启用也一样可以设置成功，所以这里先忽略
这个选项。

<pre lang="bash" line="1">
kk@fileserver:~$ sudo diff /etc/squid/squid.conf.orig /etc/squid/squid.conf
630a631
> acl igbnet src 192.1.6.0/24
677a679
> http_access allow igbnet
1114c1116
> http_port 3128
---
> http_port 3128 transparent
1945a1948
> cache_dir ufs /var/spool/squid 50000 16 256
</pre>
<pre lang="bash" line="1">
kk@fileserver:~$ sudo grep "^[^#]" /etc/squid/squid.conf
acl all src all
acl manager proto cache_object
acl localhost src 127.0.0.1/32
acl to_localhost dst 127.0.0.0/8 0.0.0.0/32
acl localnet src 10.0.0.0/8 # RFC1918 possible internal network
acl localnet src 172.16.0.0/12 # RFC1918 possible internal network
acl localnet src 192.168.0.0/16 # RFC1918 possible internal network
acl SSL_ports port 443 # https
acl SSL_ports port 563 # snews
acl SSL_ports port 873 # rsync
acl Safe_ports port 80 # http
acl Safe_ports port 21 # ftp
acl Safe_ports port 443 # https
acl Safe_ports port 70 # gopher
acl Safe_ports port 210 # wais
acl Safe_ports port 1025-65535 # unregistered ports
acl Safe_ports port 280 # http-mgmt
acl Safe_ports port 488 # gss-http
acl Safe_ports port 591 # filemaker
acl Safe_ports port 777 # multiling http
acl Safe_ports port 631 # cups
acl Safe_ports port 873 # rsync
acl Safe_ports port 901 # SWAT
acl purge method PURGE
acl CONNECT method CONNECT
acl igbnet src 192.1.6.0/24
http_access allow manager localhost
http_access deny manager
http_access allow purge localhost
http_access deny purge
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow localhost
http_access allow igbnet
http_access deny all
icp_access allow localnet
icp_access deny all
http_port 3128 transparent
hierarchy_stoplist cgi-bin ?
cache_dir ufs /var/spool/squid 50000 16 256
access_log /var/log/squid/access.log squid
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern (Release|Packages(.gz)*)$ 0 20% 2880
refresh_pattern . 0 20% 4320
acl shoutcast rep_header X-HTTP09-First-Line ^ICY.[0-9]
upgrade_http0.9 deny shoutcast
acl apache rep_header Server ^Apache
broken_vary_encoding allow apache
extension_methods REPORT MERGE MKACTIVITY CHECKOUT
hosts_file /etc/hosts
coredump_dir /var/spool/squid
</pre>

iptables则只需简单得让prerouting包做一下redir即可。

<pre lang="bash" line="1">
kk@fileserver:~$ sudo iptables -A PREROUTING -s 192.1.6.0/24 ! -d 192.0.0.0/8 -i eth0 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 3128
</pre>



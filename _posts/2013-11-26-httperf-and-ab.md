---
layout: post
title: "httperf and ab"
category: linux
tags: [web, performence, httperf, ab]
---
{% include JB/setup %}

##前期优化

首先当然先做优化，不过我本人比较倾向编译内核模块而不是
启动参数，不过方便的说，

{% highlight bash %}
cp /etc/security/limits.conf{,.orig}
cat << EOF >> /etc/security/limits.conf
* soft nofile 200000
* hard nofile 200000
EOF
{% endhighlight %}

{% highlight bash %}
cp /etc/sysctl.conf /etc/sysctl.conf.orig
cat << EOF >> /etc/sysctl.conf
# "Performance Scalability of a Multi-Core Web Server", Nov 2007
# Bryan Veal and Annie Foong, Intel Corporation, Page 4/10
fs.file-max = 5000000
net.core.netdev_max_backlog = 400000
net.core.optmem_max = 10000000
net.core.rmem_default = 10000000
net.core.rmem_max = 10000000
net.core.somaxconn = 100000
net.core.wmem_default = 10000000
net.core.wmem_max = 10000000
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_congestion_control = bic
net.ipv4.tcp_ecn = 0
net.ipv4.tcp_max_syn_backlog = 12000
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_mem = 30000000 30000000 30000000
net.ipv4.tcp_rmem = 30000000 30000000 30000000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_syncookies = 0
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_wmem = 30000000 30000000 30000000    

# optionally, avoid TIME_WAIT states on localhost no-HTTP Keep-Alive tests:
#    "error: connect() failed: Cannot assign requested address (99)"
# On Linux, the 2MSL time is hardcoded to 60 seconds in /include/net/tcp.h:
# #define TCP_TIMEWAIT_LEN (60*HZ)
# The option below is safe to use:
net.ipv4.tcp_tw_reuse = 1

# The option below lets you reduce TIME_WAITs further
# but this option is for benchmarks, NOT for production (NAT issues)
net.ipv4.tcp_tw_recycle = 1
EOF
{% endhighlight %}


##httperf

如果没有按照apache，也可以直接使用httperf，因为感觉提供的hog参数更好。

**http://www.yolinux.com/TUTORIALS/WebServerBenchmarking.html**

<pre lang="bash" >
httperf --hog --server www.website.com --num-conns 10
</pre>

**http://gwan.com/en_apachebench_httperf.html**

<pre lang="bash" >
ab -n 100000 -c 100 -t 1 -k "http://127.0.0.1:8080/100.html"
</pre>

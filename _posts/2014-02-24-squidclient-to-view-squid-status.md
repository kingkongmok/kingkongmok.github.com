---
layout: post
title: "squidclient to view squid status"
category: linux
tags: [squid, squidclient, status]
---
{% include JB/setup %}

##A simple way to test the access to the cache manager is:

**设置反向代理的方法如下，比nginx的cache测试方法要简单。**

{% highlight bash %}
squidclient mgr:info
{% endhighlight %}

# [reverse proxy](http://wiki.squid-cache.org/SquidFaq/ReverseProxy#Load_balancing_of_backend_servers)

{% highlight bash %}
cache_peer ip.of.server1 parent 80 0 no-query originserver round-robin
{% endhighlight %}

而按照刘鑫的说法(高性能网站构建实战)中的说法p77,需要vhost



{% highlight bash %}
http_port 80 accel vhost vport
{% endhighlight %}

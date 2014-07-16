---
layout: post
title: "nginx limit_rate限制下载速度"
category: linux
tags: [nginx, limit_rate]
---
{% include JB/setup %}

nginx中的limit_rate有限制下载速度的作用，配合`if(){}`来判断爬虫bot可这样来用：

{% highlight bash %}
    if ( $http_user_agent ~ Google|Yahoo|MSN|baidu ){
        limit_rate 20k;
    }
{% endhighlight %}


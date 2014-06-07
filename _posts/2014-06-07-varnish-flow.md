---
layout: post
title: "varnish flow"
category: linux
tags: [cache, varnish]
---
{% include JB/setup %}

[varnish的流程图](https://www.varnish-cache.org/trac/wiki/VCLExampleDefault)
看这个图配合下面刘鑫的解析基本能明了varnish的流程，squid方面的流程就没那么容易的总结了。当然这个都是默认的触发和过程，一般别做修改。

[这里是刘鑫的例子](http://www.programmer.com.cn/14315/)应该挺好，但还是需要先看上面流程图。他的书本都没有这个页面详细，买书还是亏了。

[配置例子](http://blog.s135.com/post/313/)比较简答能实现。

这个静态页面去除cookie的方法倒是很好，可以考虑所有静态页都去掉query string。

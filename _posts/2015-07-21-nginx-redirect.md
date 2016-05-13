---
layout: post
title: "nginx的redirect"
category: linux
tags: [nginx, redirect]
---

### https转换http

```
if ($scheme = https) {
   return 307 http://$server_name$request_uri;
}
```

***[307](http://www.cnblogs.com/cswuyg/p/3871976.html)***和***301***的区别在于：301传递过去的方法会变，例如是POST方法，301后变成GET方法

### rewrite的使用

redirect是告诉客户端去访问新的资源，客户端知道有新的资源，rewrite则是在服务器上进行，服务器直接跳转，客户端不知道有新的资源。rewrite所以会更消耗服务器资源。

* java可以在filter中处理伪静态，类似url mapping映射一个url去处理,所以应该使用redirect;
* php简单通常都在服务端配置rewrite


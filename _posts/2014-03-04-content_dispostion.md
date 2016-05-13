---
layout: post
title: "content_dispostion http response header"
category: web
tags: [download, filename, web]
---

##http中的Content-Disposition##

希望某类或者某已知MIME 类型的文件能够在访问时弹出“文件下载”对话框,能保存为相应文件名，就需要设置这个Content-Disposition. 

curl 中可以通过-J来启动这个功能，例如

{% highlight bash %}

HTTP/1.1 200 OK
Date: Tue, 04 Mar 2014 01:38:59 GMT
Server: Apache/2.2.15 (CentOS)
X-Powered-By: PHP/5.3.3
Set-Cookie: cb6e3a50e0ee66144c277afd2a359961=jdb3jich1a4r8e06adbcnno1p1; path=/
P3P: CP="NOI ADM DEV PSAi COM NAV OUR OTRo STP IND DEM"
Last-Modified: Tue, 04 Mar 2014 01:38:59 GMT
Cache-Control: max-age=86400
Content-Length: 20314
Content-Disposition: inline; filename=check_linux_stats.pl
Content-transfer-encoding: binary
Connection: close
Vary: Accept-Encoding
Content-Type: application/x-perl

{% endhighlight %}

{% highlight bash %}

这个使用通过以下命令就可以下载了。
curl -OJ URL

{% endhighlight %}

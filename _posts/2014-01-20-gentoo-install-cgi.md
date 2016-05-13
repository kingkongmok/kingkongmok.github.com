---
layout: post
title: "gentoo install cgi"
category: linux
tags: [gentoo, cgi, nginx, emerge]
---

##安装
首先安装webserver，这里安装nginx；

##cgi安装
安装了以下套件：
{% highlight bash %}
 [IP-] [  ] dev-perl/FCGI-0.740.0:0
 [IP-] [  ] dev-libs/fcgi-2.4.1_pre0910052249:0
 [IP-] [  ] www-misc/fcgiwrap-1.0.3-r1:0
 [IP-] [  ] www-servers/spawn-fcgi-1.6.3-r1:0
{% endhighlight %}

##配置
根据[arch](https://wiki.archlinux.org/index.php/nginx)，这里可以看到spawn-fcgi调用cgiwrap的操作方法如下：
{% highlight bash %}
spawn-fcgi -a 127.0.0.1 -p 9000 -f /usr/sbin/fcgiwrap
{% endhighlight %}
按上面的理解，spawn-fcgi是一个管理，类是fpm的一个专门管理spawn的程序。
fcgiwrap是一个公共接口，类是FCGI的东西。
而dev-perl/FCGI则提供了perl的解析，作为FGCI的接口使用。

##设置自动启动
spawn-fcgi本身不能启动CGI，但可以调用fcgi，所以根据[arch](https://wiki.archlinux.org/index.php/nginx)的方法，可以使用init.d来自动调用；
{% highlight bash %}
kk@gentoo /etc/init.d $ sudo ln -s spawn-fcgi spawn-fcgi.fcgiwrap

kk@gentoo /etc/init.d $ sudo /etc/init.d/spawn-fcgi.fcgiwrap start
* Caching service dependencies ...                                     [ ok ]
* Starting FastCGI application fcgiwrap ...
spawn-fcgi: child spawned successfully: PID: 2842                      [ ok ]

kk@gentoo /etc/init.d $ sudo rc-update add spawn-fcgi.fcgiwrap default
* service spawn-fcgi.fcgiwrap added to runlevel default

{% endhighlight %}

然后根据刚刚的配置，我修改了/etc/conf.d/spawn-fcgi文件，如下
{% highlight bash %}
kk@gentoo ~ $ grep "^[^#]" /etc/conf.d/spawn-fcgi
FCGI_SOCKET=
FCGI_ADDRESS=127.0.0.1
FCGI_PORT=9000
FCGI_PROGRAM=/usr/sbin/fcgiwrap
FCGI_CHILDREN=1
FCGI_CHROOT=
FCGI_CHDIR=
FCGI_USER=nginx
FCGI_GROUP=nginx
ALLOWED_ENV="PATH"
{% endhighlight %}

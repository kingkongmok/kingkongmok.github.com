---
layout: post
title: "gentoo install cgi"
category: linux
tags: [gentoo, cgi, nginx, emerge]
---
{% include JB/setup %}

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

##设置自动启动
spawn-fcgi本身不能启动CGI，但可以调用fcgi，所以根据[arch](https://wiki.archlinux.org/index.php/nginx)的方法，可以使用init.d来自动调用；
{% highlight bash %}
kk@gentoo ~ $ ls -l /etc/*.d/*cgi*
-rw-r--r-- 1 root root 2387 2014-01-20 15:43 /etc/conf.d/spawn-fcgi
lrwxrwxrwx 1 root root   10 2014-01-20 15:36 /etc/conf.d/spawn-fcgi.fcgiwrap -> spawn-fcgi
-rwxr-xr-x 1 root root 3211 2014-01-20 15:30 /etc/init.d/spawn-fcgi
lrwxrwxrwx 1 root root   10 2014-01-10 11:59 /etc/init.d/spawn-fcgi.fcgiwrap -> spawn-fcgi
{% endhighlight %}

然后根据刚刚的配置，我修改了/etc/conf.d/spawn-fcgi.fcgiwrap文件，如下
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

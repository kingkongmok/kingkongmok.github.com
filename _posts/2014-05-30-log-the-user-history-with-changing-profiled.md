---
layout: post
title: "log the user history with changing profile.d 简单监控用户使用命令"
category: linux
tags: [history, log]
---

[有个巧妙的建议](https://github.com/kingkongmok/linux/blob/master/etc/profile.d/accountlog.sh)来记录root用户登录后的记录。但这个方法是否能躲过恶意用户的删除就很难说。估计还是要syslog之类的服务器才能解决。
不过我以前一直以为可以通过修改last和hist -c就能删除记录还是比较小看log能力了，下次还是需要注意所有的profile, bashrc, init, 甚至是PS。

{% highlight bash %}
[root@localhost data]# cd accountlog/
[root@localhost accountlog]# ls
2012
[root@localhost accountlog]# cd 2012/
[root@localhost 2012]# ls
01  02  03  04  05  06  07
[root@localhost 2012]# cd 07/
[root@localhost 07]# ls
09  10  12  13  14  15  16  19  20  21
[root@localhost 07]# cd 21
[root@localhost 21]# ls
root  
{% endhighlight %}



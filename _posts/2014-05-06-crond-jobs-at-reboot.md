---
layout: post
title: "cron.d jobs at reboot"
category: linux
tags: [cron, reboot]
---
{% include JB/setup %}

之前一直出现不能运行在/etc/cron.d里面的cron jobs，syslog异常如下

{% highlight bash %}
2014-05-06T08:52:01.348153+08:00 gentoo crond[3302]: (root) BAD FILE MODE (/etc/cron.d/autossh)
{% endhighlight %}

然后根据[这里](http://www.cyberciti.biz/faq/unix-linux-cron-bad-file-mode-error/)的说法，需要chmod，

{% highlight bash %}
sudo chmod 644 /etc/cron.d/autossh

$ ls -lh /etc/cron.d/autossh
-rw-r--r-- 1 root root 77 2014-03-13 09:05 /etc/cron.d/autossh
{% endhighlight %}


---
layout: post
title: "log with psad and iptables"
category: linux
tags: [log, iptables, psad, attack, security]
---
{% include JB/setup %}

##iptables and syslogd
iptables能drop，reject和log各种不良的数据包，通过syslog能把信息记录。psad能通过该log分析和警报。例如超过1500个数据包的nmap，iptables通过syslog记录后，psad就将会将其定义为DANGER_LEVEL4。

如果DANGER_LEVEL4，psad还能通过`AUTO_IDS_DANGER_LEVEL`参数(当然，也可以自定义DL5的数据包数)让其断开链接。

{% highlight bash %}
### Block all traffic from offending IP if danger
### level &gt;= to this value
AUTO_IDS_DANGER_LEVEL 5;

### Set the auto-blocked timeout in seconds (the default
### is one hour).
AUTO_BLOCK_TIMEOUT 3600;
{% endhighlight %}
##psad只需简单修改邮箱地址、机器名就能正常运作。
{% highlight bash %}
kk@fileserver:~$ diff /etc/psad/psad.conf*
19c19
< EMAIL_ADDRESSES kk@debian.kk.igb;
---
> EMAIL_ADDRESSES root@localhost;
22c22
< HOSTNAME fileserver.kk.igb;
---
> HOSTNAME _CHANGEME_;
204c204
< EMAIL_ALERT_DANGER_LEVEL 3;
---
> EMAIL_ALERT_DANGER_LEVEL 1;
{% endhighlight %}
##内网只需DL超过3的信息才发邮件记录。
<pre lang="bash" line="1">
### Only send email alert if danger level &gt;= to this value.
EMAIL_ALERT_DANGER_LEVEL 3;
</pre>
更多详细信息可以登录主机后查询 `/var/log/psad/`

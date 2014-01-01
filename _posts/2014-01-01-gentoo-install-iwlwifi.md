---
layout: post
title: "gentoo install iwlwifi"
category: linux
tags: [gentoo, wifi, iwlwifi, kernel]
---
{% include JB/setup %}

##install sys-firmware/iwl6000-ucode
**[ iwl6000 sucess ] ( http://bpaste.net/show/163406/ )**

##update kernel 
**wifi support according [ gentoo wifi howto ]( http://wiki.gentoo.org/wiki/Wifi )**
**[ detail ] (http://bpaste.net/show/163407/)**

{% highlight bash %}
kk@gentoo:~$ sudo lspci | grep net -i
00:19.0 Ethernet controller: Intel Corporation 82577LM Gigabit Network Connection (rev 06)
03:00.0 Network controller: Intel Corporation Centrino Advanced-N 6200 (rev 35)
{% endhighlight %}

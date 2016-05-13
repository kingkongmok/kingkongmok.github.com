---
layout: post
title: "epel on centos"
category: linux
tags: [centos, yum, nginx, epel]
---

在的centos的默认源里是不提供nginx和 php5-fpm这些包的，baidu上介绍较多的方法是编译。 google上推荐较多的解决方法是使用EPEL源来实现的。

在[fedoraproject](http://fedoraproject.org)的解析中可以得知，这个包应该算
是fedora的一个官方包，有点像debian的官方backports，无论如何能快速方便安全得解决centos的软件不足问题。EPEL也是除了oracle外唯一能被我选用的[repo](http://fedoraproject.org/wiki/EPEL#What_is_Extra_Packages_for_Enterprise_Linux_.28or_EPEL.29.3F)

添加repo后重新yum update即可


<pre lang="bash" line="1">su -c 'rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm'</pre>


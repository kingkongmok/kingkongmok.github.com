---
layout: post
title: "patch and diff"
category: linux
tags: [patch, diff]
---
{% include JB/setup %}

**[The Ten Minute Guide to diff and patch](http://jungels.net/articles/diff-patch-ten-minutes.html)**

##对于文件

{% highlight bash %}
diff -u original.c new.c > original.patch
patch original.c < original.patch
{% endhighlight %}

##对于文件夹

{% highlight bash %}
diff -rupN original/ new/ > original.patch
patch -Np1 < original.patch
{% endhighlight %}

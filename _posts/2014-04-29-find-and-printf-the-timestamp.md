---
layout: post
title: "find and printf the timestamp"
category: bash
tags: [find, printf]
---
{% include JB/setup %}

[这里](http://cygwin.com/ml/cygwin/2005-01/msg00672.html) 有帖子提供find的bug，并给出一个很好的shell来测试printf的时间戳。


{% highlight bash %}
$ for fmt in H I k l p Z M S @ a A b h B m d w j U W Y y r T X c D x +
> do echo "$fmt: `find /etc/passwd -printf \"%T$fmt\"`"
> done
H: 15
I: 03
k: 15
l:  3
p: PM
Z: EDT
M: 36
S: 42
@: 1097523402
a: Mon
A: Monday
b: Oct
h: Oct
B: October
m: 10
d: 11
w: 1
j: 285
U: 41
W: 41
Y: 2004
y: 04
r: 1097523402            time, 12-hour (hh:mm:ss [AP]M)
T: 1097523402            time, 24-hour (hh:mm:ss)
X: 15:36:42
c: Mon Oct 11 15:36:42 2004
D: 1097523402            date (mm/dd/yy)
x: Mon Oct 11 2004
+: +                     Date and time, separated by '+'
{% endhighlight %}

非常好用呢。

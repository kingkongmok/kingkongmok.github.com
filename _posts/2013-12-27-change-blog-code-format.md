---
layout: post
title: "change blog code format"
category: linux
tags: [blog, highlight, pre, code]
---
{% include JB/setup %}

##修改代码区

之前由于使用vim的vS比较方便实现代码的pre标签，但更新现在的jekyll后报错。所以现在重新需要写highlight区。


{% highlight bash %}
sed -i 's/^<pre.*$/{% highlight bash %}/; s/^<\/pre>/{% endhighlight %}/'  filename
{% endhighlight %}

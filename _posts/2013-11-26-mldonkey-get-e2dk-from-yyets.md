---
layout: post
title: "mldonkey get e2dk from yyets 人人影视获取e2dk地址"
category: perl
tags: [mldonkey e2dk yyets]
---
{% include JB/setup %}

##通过curl获取e2dk

在人人影视中放出的源，在mldoneky中无法粘贴。又没有mldonkey for firefox addons的情况下，用perl抽ed2k的地址如下：

{% highlight bash %}
perl -ne 'for(split){print"$&\n"if/ed2k:\/\/[^"]+/}' html
{% endhighlight %}

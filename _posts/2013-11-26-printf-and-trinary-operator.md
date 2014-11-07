---
layout: post
title: "printf and trinary operator"
category: perl
tags: [printf, trinary operator, du]
---
{% include JB/setup %}

##As in C, ?: is the only trinary operator. It’s often called the conditional operator
because it works much like an if-then-else,

今天获得一个perl，觉得需要熟悉，如下：

{% highlight perl %}
du -b --max-depth 1 | sort -nr | perl -pe 's{([0-9]+)}{sprintf"%.1f%s", $1>=2**30? ($1/2**30, "G"): $1>=2**20? ($1/2**20, "M"):$1>=2**10? ($1/2**10, "K"): ($1, "")}e'
{% endhighlight %}

{% highlight perl %}
du -b --max-depth 1 | sort -nr | perl -pe 's#\d+#$&>2**30?sprintf"%.2fG",$&/2**30:$&>2**20?sprintf"%.2fM",$&/2**20:$&>2**10?sprintf"%.2fK":$&#e'
{% endhighlight %}

其中的三元操作可以分析如下：

{% highlight perl %}
my $width = 12;
my $size = ($width < 10) ? "small" :
($width < 20 ) ? "medium" :
($width < 30 ) ? "large" :
"xxl" ;
print $size ;
{% endhighlight %}

另外，s///e这个用法也需要注意，如果不加e，不能使用sprint获得新值。

## size --human-readable

```bash
echo 12345678 |perl -ne 'foreach$f(qw/B KB MB GB/){if($_<1024){printf"%.2f%s\n",$_,$f; last} $_=$_/1024}'
```

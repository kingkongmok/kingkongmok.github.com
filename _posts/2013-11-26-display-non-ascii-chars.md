---
layout: post
title: "display Non Ascii chars"
category: perl
tags: [ascii, perl ]
---

需要判断语句中是否包含中文，这个不会，但要排除不包含英
文也能达到目的：
通常判断ascii码大于等于128的就不是英文了。但其实键盘能显示处理的是 32< ord(string) < 126，由这两
个来判断应该还可以。

{% highlight perl %}
perl -lne 'while(/(.)/g){print  if ord($1) >= 128}' in1.txt 
{% endhighlight %}

**http://www.ascii.cl/htmlcodes.htm**
**判断 32 < ascii < 126, 这个来判断是否html语言似乎不足够，只能判断是否英文了。**

{% highlight perl %}
perl -lne 'while(/(.)/g){print  if 32 > ord($1) || ord($1) > 126}' in1.txt
{% endhighlight %}

**由于是/./g，每行的每个字符都会判断，所以有很多重复。使用last能取消改行重复，不需要另外sort -n | uniq**

{% highlight perl %}
perl -ne 'while(/(.)/g){if (ord($1)>128){print ; last}}' file
{% endhighlight %}

##只显示整行都是ascii的段落

{% highlight perl %}
perl -ne 'while(/(.)/g){ if(ord($1)>128){push@array,$.;last;}}; print unless grep {$.==$_}@array'
{% endhighlight %}

{% highlight perl %}
my@array;
while ( <> ) {
    while ( /(.)/g ) {
        if ( ord($1)>128 ) {
            push @array, $. ;
            last ;
        }
    }
    print $_ unless grep {$.==$_} @array ;
}
{% endhighlight %}

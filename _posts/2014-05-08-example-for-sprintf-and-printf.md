---
layout: post
title: "example for sprintf and printf"
category: perl
tags: [printf, sprintf]
---
{% include JB/setup %}

sprintf通常需有e在s///后面，例如

{% highlight bash %}
while ( <$fh> ) {
    print s/.*/sprintf"%02d",$i++/re;
}
{% endhighlight %}

而printf可以直接使用例如

{% highlight bash %}
while ( <$fh> ) {
    printf "%02d\n",$i++;
}
{% endhighlight %}

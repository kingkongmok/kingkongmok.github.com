---
layout: post
title: "rename with perl"
category: perl
tags: [rename, perl]
---
{% include JB/setup %}


### numeric

{% highlight bash %}
perl -e 'rename$_,sprintf("%03d.pdf",++$a)for@ARGV' *.pdf
{% endhighlight %}

这个用来把文件夹里面pdf的文件全部改名为数字名称。

另外，也可以哦嗯perl-rename加sprintf功能

{% highlight bash %}
perl-rename -n 's/.*/sprintf"%04d",$i++/e' *.pdf
{% endhighlight %}

Linux本身自带的rename非常好用,而且支持部分perl语言，但好像不支持printf，遇到数字比较麻烦，但空格
和字母则ok，如下：

<pre lang="bash" src="http://www.perlmonks.org/?node_id=632437">
kk@debian:/tmp/test$ touch 23423\ 234afadf\ \ \ 234.sdf
kk@debian:/tmp/test$ rename -n 's/\d+ //; s/\s+/_/g' *
23423 234afadf   234.sdf renamed as 234afadf_234.sdf
</pre>

需要将2.jpg，22.jpg，222.jpg变为002.jpg, 022.jpg, 222.jpg的方法:

```
perl-rename  's/$_/sprintf"%07s",$_/e' *
```

另外需要222.jpg改名为22200000.jpg这样的需求
{% highlight bash %}
ls |perl -pe 'while(length$_<20){s/(?=\.[^.]+$|$)/0/}'
{% endhighlight %}

### subfolder prefix

http://bpaste.net/show/244959/

{% highlight bash %}
find -maxdepth 2 -type f -print0  | xargs -r0n1 | perl-rename -n 's#\b/##'
find . -type f | sed -r 's@([^/])/([^/]+)/(.*)@mv & \1/\2\3@'
find -maxdepth 2 -type f |perl -lne '$file=$_;s/\b\///g;rename $file,$_'
{% endhighlight %}

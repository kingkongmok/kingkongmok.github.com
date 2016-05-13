---
layout: post
title: "perl encoding"
category: perl
tags: [encoding, perl, utf8, unicode]
---

##测试
**撰写本文时，还没搞好我需要的东西，本文作为记录**

在介绍处理[ encoding ]( http://stackoverflow.com/questions/627661/how-can-i-output-utf-8-from-perl )中，我发现perl有4种方法处理encoding;

* [ commandline ] ( http://perldoc.perl.org/perlrun.html#%2A-C-%5B%5Fnumber/list%5F%5D%2A )

{% highlight perl %}
perl -CSDL -le 'print "\x{1815}"';
{% endhighlight %}

* [ binmode ] ( http://perldoc.perl.org/functions/binmode.html )

{% highlight perl %}
binmode(STDOUT, ":utf8");          #treat as if it is UTF-8
binmode(STDIN, ":encoding(utf8)"); #actually check if it is UTF-8
{% endhighlight %}


* [ PerlIO ] ( http://perldoc.perl.org/PerlIO.html )

{% highlight perl %}
open my $fh, ">:utf8", $filename
    or die "could not open $filename: $!\n";

open my $fh, "<:encoding(utf-8)", $filename
    or die "could not open $filename: $!\n";
{% endhighlight %}


* [ open pragma ] ( http://perldoc.perl.org/open.html )

{% highlight perl %}
use open ":encoding(utf8)";
use open IN => ":encoding(utf8)", OUT => ":utf8";
{% endhighlight %}

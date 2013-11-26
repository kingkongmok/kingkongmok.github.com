---
layout: post
title: "perl array grep example"
category: perl
tags: [perl, array, grep]
---
{% include JB/setup %}

##例子如下

<pre lang="perl" line="24">
my      @array = qw/1 2 3 4 5 1a 2b 3c 4d 5e a b c d e /;
my      @newarray = grep { s/a/A/g, $_ }  @array;

foreach my $line ( grep /a/i, @newarray ) {
    print "$line\n" ;
}
</pre>

##结果如下：

<code>
perl test.pl
1A
A
</code>

---
layout: post
title: "count random numb appearance times"
category: perl
tags: [count, perl, random, times]
---
{% include JB/setup %}

{% highlight perl %}
#!/usr/bin/perl 
use strict;
use warnings;
my@array=1..10;
my$numb=0;
my%hash;
while ( $numb<1000 ) {
    $hash{int(rand@array)}++ ;
    $numb++;
}
#print join":",keys%hash;
my$k;
my$v;
my$sumk;
my$sumv;
while ( ($k,$v)=each%hash ) {
    print "$k\t$v\n" ;
    $sumk+=$k; 
    $sumv+=$v; 
}
BEGIN{
print "keys\tvalues\n"
}
END 
{
print "the sum of key is $sumk\n" ;
print "the sum of val is $sumv\n" ;
}
{% endhighlight %}

<code>keys      values
6       92
3       106
7       93
9       106
2       105
8       102
4       99
1       102
0       94
5       101
the sum of key is 45
the sum of val is 1000
</code>

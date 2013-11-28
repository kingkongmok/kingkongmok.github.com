---
layout: post
title: "using hash counting in string"
category: perl
tags: [count, hash, string, perl, gsm]
---
{% include JB/setup %}

##换行的字符串分类

qq群里面有朋友问如何使得有大小写并有换行的字符串分类并 列明数量，以下是方法。

<pre lang="perl">
#!/usr/bin/perl
use strict;
use warnings;

$_=" Apple banana orange pear
 Pear apple apple pear
 Banana banana apple orange" ;

my%h;
while (/(\w+)(?=\s)/igsm ) {
    $h{lc$1}++ ;
}

while ( (my$k,my$v)=each%h ) {
    print "$k\t$v\n"
}
</pre>


<code>
banana  3
apple   4
orange  1
pear    3
</code>




---
layout: post
title: "Multi-lines on Perl 多行文本的Perl处理"
category: perl
tags: [count, while, txt, multi]
---
{% include JB/setup %}

记录一下perl的多行正则用法

### count the words in multi-line

```perl
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
```

### $/ $INPUT_RECORD_SEPARATOR

```perl
open my $fh , "test.txt" or die $!; 

$/=undef ;
while (<$fh>) {    
    while ( m{ \b(\w\S+)(\s+\1)+\b}xg) {
        print "dup word '$1' at paragraph $.\n";
    } 
}
```


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

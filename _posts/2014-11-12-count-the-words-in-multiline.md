---
layout: post
title: "count the words in multi-line"
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

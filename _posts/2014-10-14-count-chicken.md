---
layout: post
title: "count chicken"
category: perl
tags: [perl, awk]
---
{% include JB/setup %}

有个题目
中国古代数学家张丘建在他的《算经》中提出了一个著名的“百钱百鸡问题”：一只公鸡值五钱，一只母鸡值三钱，三只小鸡值一钱，现在要用百钱买百鸡，请问公鸡、母鸡、小鸡各多少只？

```perl
#!/usr/bin/env perl 
use warnings;

my ($a, $b, $c);  
$a=$b=$c=0 ;
my $count ;

my ($sum)=@ARGV;

while ( $a<$sum ) {
    $b=0;
    while ( $b< $sum ) {
        $c=0;
        while ( $c<$sum ) {
            $count++ ;
            if (  $a*5+$b*3+$c*1/3 == $sum && $a+$b+$c == $sum ) {
                print "$a $b $c\n" ;
            }
            $c++ ;
        }
        $b++ ;
    }
    $a ++ ;
}

print $count ;
```

```bash
awk -va=200 'BEGIN{for(i=1;i<a/5;i++)for(j=1;j<=a/3;j++)for(k=3;k<=a*3;k+=3)if(i+j+k==a && i*5+j*3+k/3==a)print i,j,k}'
```

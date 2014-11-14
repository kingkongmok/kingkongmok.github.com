---
layout: post
title: "perl counting"
category: perl
tags: [count]
---
{% include JB/setup %}

{% highlight bash %}
kk@ins14 ~/workspace/kingkongmok.github.com $ sudo cat /var/log/syslog | perl -MData::Dumper -ne 'next unless /^Sep  2/../^Sep\s+3/; while(/((master_spawn|kernel|error))/g){$h{$1}++} }{ print Dumper\%h'
$VAR1 = {
          'master_spawn' => 595,
          'kernel' => 419,
          'error' => 2
        };
{% endhighlight %}

这个是用来检查某段之间（从Sep  2到Sep  2段落）间，出现以上词语的次数。

### random and count

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

### 百钱百鸡问题

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

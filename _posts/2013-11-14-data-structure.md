---
layout: post
title: "data structure Perl的简单数据结构"
category: perl
tags: [data, structur, aoa, hoa, hoh, aoh]
---

##data structure

**hoh是考虑修正一下文件的：**

https://github.com/kingkongmok/perl/blob/master/billConvert.pl

{% highlight  perl %}
use strict;
use warnings;

open my$fh, "< /home/kk/test.txt" ;

my@array ; 
my%hash ;
my$scalar ;

# scalar, array, hash, glob

#-------------------------------------------------------------------------------
#  test for aoa
#-------------------------------------------------------------------------------
while ( <$fh> ) {
   push @array,[split] ; 
}
foreach my $aoa ( @array ) {
    print join" ",@$aoa;
    print "\n";
}

#-------------------------------------------------------------------------------
#  test for hoa
#-------------------------------------------------------------------------------
while ( <$fh> ) {
    chomp(my($key, $value) =  split" ",$_,2);
    $hash{$key}=[split" ",$value] ; 
}

while ( my($keys,$values)=each%hash ) {
    my@values = @$values ;
    print "$values[1]\n" ;
}

#来一个补充，是作为insert value的。

my $longstring = "kk kingkong mok
ck camilla kuo" ;
my %hash ;
foreach my $item ( split/\n/,$longstring ) {
    my ($k, $v) = split/\s+/,$item,2;
    $hash{$k} = [ split/\s/,$v ] ; 
    my @array = ("home", "here" ) ;
    foreach  ( @array ) {
        push @{$hash{$k}},  $_ ;
    }
}

另外今天发现个很好的方法：

```
perl -e '$h{k}=[1,2]; push @{$h{k}},3; print join" ",@{$h{k}}, "\n"'
```

#-------------------------------------------------------------------------------
#  test for aoh
#-------------------------------------------------------------------------------


while ( <$fh> ) {
    chomp ;
    push @array, { split" ",$_,2 } ; 
}
while ( @array ) {
    my($key, $value) = each shift @array ;
    print "$key $value\n" ;
}

#-------------------------------------------------------------------------------
#  test for hoh 
#-------------------------------------------------------------------------------


while ( <$fh> ) {
    chomp;
    my($key1,$value1)=split" ",$_,2; 
    my($key2,$value2)=split" ",$value1,2;
    $hash{$key1}{$key2}=$value2 ;
}

while ( my($key1,$value1)=each%hash ) {
    while ( my($key2,$value2)=each%$value1 ) {
        print "$key1 $key2 $value2\n" ;
    }
}

{% endhighlight %}

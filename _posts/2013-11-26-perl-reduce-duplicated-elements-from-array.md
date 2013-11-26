---
layout: post
title: "perl reduce duplicated elements from array"
category: perl
tags: [perl, duplicated, array]
---
{% include JB/setup %}

##$hash{key}++

可以使用之前常用的 $h{$_}++ 

<pre lang="perl" line="22">
my @array = qw / 1  2 1 2 3 1 /;

for  ( @array ) {
     print unless $h{$_}++ ;
}
</pre>

##slice

也可以使用新学到的slice方法，其实都是通过hash的key写入。

<pre lang="perl" line="22">
@hasharray{qw/1 2 1 2 1 1 2 3 4 3 4 1 2 3 4 /}=() ;
print join "\t",keys %hasharray;
</pre>

##slice的两个例子如下：

<pre lang="perl" line="22">
%saw=(1=>2,3=>4,5=>6);
@saw{a,b,c}=(1,2,3);
@in=('192.168.1.100','127.0.0.1','127.0.0.1','192.168.1.101','192.168.102');
print @saw{1,3};
print @in[0,3];
</pre>

<pre lang="perl" line="22">
@array1= qw / a b c /;
@array2 = qw /1 2 3 /;
%hash;
@hash{@array1}=@array2 ;
use Data::Dumper;
print Dumper(%hash);
</pre>

##遇到3个元素就显示

<pre lang="perl">
my      @array = qw/ 1 1 1 2 2 3 /;
my %h ;
foreach my $line ( @array ) {
    print "$line\n" if $h{$line}++ eq 3;
}
</pre>

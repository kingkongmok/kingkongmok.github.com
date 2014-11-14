---
layout: post
title: "perl sort"
category: perl
tags: [perl, sort, cmp, column]
---
{% include JB/setup %}

##方法一，之前抄的

{% highlight perl %}
#!/usr/bin/perl 
use strict;
use warnings;

open FILE, "<", "testinput.txt" or die "error: $!" ;
chomp (my @array = <FILE>) ;
my @sortedarray = map { $_->[0] } sort {$a->[1] <=> $b->[1]} map {[$_, (split)[1]]} @array ;


#use Data::Dumper;
#print Dumper(@sortedarray);

foreach my $line ( @sortedarray  ) {
    print "$line\n" ;
}

{% endhighlight %}

##方法二，依然调用map但直接拆数组。

{% highlight perl %}
open FILE, "<", "testinput.txt" ;
my @array = <FILE>;
my @splitedarray = sort {$a->[1] <=> $b->[1]} map { [(split) ] } @array; 

#use Data::Dumper;
#print Dumper(@splitedarray);
    

foreach my $aoa (@splitedarray  ) {
    foreach my $element (@{$aoa}  ) {
        print "$element\t" ;
    }
    print "\n";
}
{% endhighlight %}

##方法三，顺便测试push，臃肿的表现。

{% highlight perl %}
perl -lane ' push(@newarray, $_ ); END { foreach ( map {$_->[0]} sort { $a->[1] <=> $b->[1] } map {[$_, (split)[2]]} @newarray) { print } }' testinput.txt
{% endhighlight %}

##方法四，数组表现。

{% highlight perl %}
perl -ae 'print map {$_->[0]}  sort {$a->[1] <=> $b->[1]}  map {[ $_, (split)[2]]} <>'
{% endhighlight %}


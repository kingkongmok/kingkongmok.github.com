---
layout: post
title: "slice by paragraph Perl的行截取"
category: perl
tags: [slice, paragraph]
---
{% include JB/setup %}
**这样的字段，需要查询exon的在tran中间的exon次数，例如这里是2 3**
{% highlight perl %}
kk@R61e:~$ cat test.txt
tran
exon
exon
tran
exon
exon
exon
{% endhighlight %}

{% highlight perl %}
use strict;
use warnings;
 
open FILE , "< /home/kk/test.txt" ;
chomp(my @string = <FILE>) ;
 
 
my %h ;
my $i = 0 ;
for ( @string ) {
    if (/tran/){
        $i++;
        next ;
    }
    $h{$i}++;
}
 
use Data::Dumper;
print Dumper(\%h);
{% endhighlight %}

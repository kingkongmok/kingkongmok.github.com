---
layout: post
title: "perl get array from %3 每3个中获取"
category: perl
tags: [perl, array, '%3']
---
{% include JB/setup %}

{% highlight perl %}
use strict;
use warnings;

my @words = qw(a b c d e f g h i j k l m r);
my      $i  ;
my @list = grep {not $i++ %3} @words ;

use Data::Dumper;
print Dumper(@list);
{% endhighlight %}

{% highlight perl %}
Press ENTER or type command to continue
$VAR1 = 'a';
$VAR2 = 'd';
$VAR3 = 'g';
$VAR4 = 'j';
$VAR5 = 'm';
{% endhighlight %}

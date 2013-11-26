---
layout: post
title: "smart match ~~"
category: perl
tags: [smart match, '~~', perl]
---
{% include JB/setup %}

<code>
$key ~~ %hash       # Does $key exist in %hash ?
$value ~~ @array    # Does $value exist in @array?
</code>

<pre lang="perl">
my @primary = ("red", "blue", "green");
    if (@primary ~~ "red") { # false
        print "primary smartmatches red";
    }

    if ("red" ~~ @primary ) { #true
        print "red smartmatches primary";
    }
</pre>


##以下是失败的例子，不能这样用
<pre lang="perl">
my@array1=qw/1 2 3 /; 
my@array2=qw/1 2 3 4/;
print "yes" if @array ~~ @array2;
</pre>

<pre lang="perl">
#测试中，发现 ~~ 后面需要变量，以下这个失败
 if 2 ~~ qw(1 2 3) #false
 
#但这个是成功的，奇怪需要更多测试
# Print only lines 13, 19 and 67
perl -ne 'print if int($.) ~~ (13, 19, 67)' 
# Print all lines from line 17 to line 30
perl -ne 'print if int($.) ~~ (17..30)'
</pre>



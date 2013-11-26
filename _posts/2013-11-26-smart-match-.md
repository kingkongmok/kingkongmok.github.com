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


perl中对于两个数组的对比方法，一般能google到的都是利用e
xists的方法进行的。
exists是寻找该key是否在hash中存在。所以，keys必须是uniq的。这个不太方便。
复习了一下linux的命令，发现diff和comm其实还是比较能帮忙的，真的要做对比分析，还是需要用到这些。

注意的是，diff是要对比所有字符，包括不可见字符。记得需要的时候要加  -Wb
-w, --ignore-all-space
-B, --ignore-blank-lines

comm是分3列来显示的，-1-2-3分别是surpress（不显示）相应列数，这个单词误我好久！

<pre lang="perl">
my@a=qw/1 2 3 /;
my@b=qw/1 2 3 4 5/;
my%h;
@h{@a}=() ;

print "yes" if @a ~~ %h ;

print grep {!exists $h{$_} } @b ;
</pre>

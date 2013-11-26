---
layout: post
title: "compare two strings and display the common"
category: perl
tags: [regex, perl, common]
---
{% include JB/setup %}

用于匹配两个string的match部分，是使用 m//进行的，其中(.+) \1部分就是用来匹配相关字段的。使用\0 null字符分开。
如果需要匹配.+(.+)$，要在中间加？变成 .+?(.+)$;
如果需要匹配^(.+).+， 则不需要加?;


##匹配尾段

<pre lang="perl">
$first="abcdaaaaaa";
$second="1234aaaaa";
"$first\0$second" =~ m/^.+?(.+)\0.+?\1$/;
print $1 ;
</pre>

##匹配开头

<pre lang="perl">
$first="aaaaaaABCD";
$second="aaaba12345";
"$first\0$second" =~ m/^(.+).+\0\1.+$/;
print $1 ;
</pre>


##匹配中间

<pre lang="perl">
$first="abcdaaaaaABCD";
$second="1234aaaaaa5678";
"$first\0$second" =~ m/^.+?(.+).+?\0.+?\1.+?$/;
print $1 ;
</pre>

##应用

<pre lang="perl">
print $1 if "$foo\0$bar" =~ m/.*?(.+).*?\0.*?\1.*?/;
</pre>

---
layout: post
title: "minus by even and odd 偶数行减奇数行所得到的值"
category: perl
tags: [minus, even, odd]
---

有个奇葩同学要求偶数行减奇数行所得到的值，随意测试一下
如下，待修正。
```
cat test.txt | perl -ne 'chomp; if($.%2==1){push @a, $_}else{push @b, $_}}{for(0..$#a){printf"%s-%s=%d\n", $a[$_],$b[$_],$a[$_]-$b[$_]}' 
```

---
layout: post
title: "getopt in perl"
category: perl
tags: [getopt, perl, shell, ]
---

##bash中的实现方法
bash当然也有getopt，利用bash的vim模块能快速调用出`usage`和 `getopts` function。

##perl中的方法
perl有pm来实现，一般可使用`Getopt::Long`和`Getopt::Std`来实现。

##examples
**[例子](https://github.com/kingkongmok/perl/blob/master/getopt.pl)**

这里通过`Getopt::Std`简单实现getopts，但未包括usage，后续再写。



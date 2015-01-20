---
layout: post
title: "perl debugger editor like vim"
category: perl
tags: [debugger, editor]
---
{% include JB/setup %}


[这里](http://www.perlmonks.org/?node_id=838813)的介绍，perl的editor可以像vim那样输入，只需要安装简单的模块即可。

```
#!/usr/bin/perl

use strict;
use warnings;
use CPAN;

CPAN::Shell->install(

"Term::ReadKey",
"Term::ReadLine::Gnu",
"Term::ReadLine::Perl");
```

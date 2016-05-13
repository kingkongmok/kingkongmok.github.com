---
layout: post
title: "perl debugger editor like vim"
category: perl
tags: [debugger, editor]
---

### debug editor like vim

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

也就是安装

```
Term::ReadKey
Term::ReadLine::Gnu
Term::ReadLine::Perl
```

### 定位

在debugger中可以用以下命令来break某个点：

```
b 71 $k>70
```

也可以通过修改***warnings***， 以下可以在debugger时，遇到异常就停下：

```
use warnings FATAL => qw(uninitialized);
```

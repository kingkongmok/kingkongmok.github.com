---
layout: post
title: "perl在open时一起使用encoding和pipe的方法"
category: 
tags: []
---
{% include JB/setup %}

好像比较少看到有介绍同时使用open的encoding和pipe方法，

### 自己查询的方法：

```
use utf8;
open my $fh, '-|:encoding(gbk)',  "tail -c 300m $logfile" || die $!;
```

### mojo的open介绍

[这里的mojo做open介绍](http://mojolicio.us/perldoc/perlopentut)，可以借鉴。

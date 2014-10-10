---
layout: post
title: "markdown example"
category: markdown
tags: [git, markdown]
---
{% include JB/setup %}

# 贴图

使用以下语法可以贴图，记得设置相应路径即可。图是`蓝风一梦`，谢谢。

```
![](/Pictures/20141010_markdown.jpg
```

## 例子

![](/Pictures/20141010_markdown.jpg)

# bash 脚本
```bash
echo hello world
echo helloworld!
```

# perl script
```perl
#!/usr/bin/perl
use strict;
use warnings;

$_=" Apple banana orange pear
Pear apple apple pear
 Banana banana apple orange" ;

my%h;
while (/(\w+)(?=\s)/igsm ) {
    $h{lc$1}++ ;
}

while ( (my$k,my$v)=each%h ) {
    print "$k\t$v\n"
}
```

# 测试[markdown](http://jbt.github.io/markdown-editor/)的一个在线页


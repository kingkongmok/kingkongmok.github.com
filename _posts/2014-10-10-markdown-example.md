---
layout: post
title: "markdown example"
category: markdown
tags: [git, markdown]
---

## 语法高亮

多谢`果冻(wd) `的提醒，我去google了一番找到了[语法高亮的解决方法](http://demisx.github.io/jekyll/2014/01/13/improve-code-highlighting-in-jekyll.html), 和修改_config.yml使用**```**的方法

```
diff --git a/_config.yml b/_config.yml
index d87e1e6..e9a4cfd 100644
--- a/_config.yml
+++ b/_config.yml
@@ -131,4 +131,5 @@ JB :
 #https://help.github.com/articles/migrating-your-pages-site-from-maruku
 #
 #http://jekyllrb.com/docs/extras/
-markdown: kramdown
+#markdown: kramdown
+markdown: redcarpet
```

**看`_layouts/default.html`文件的修改**

```bash
diff --git a/_layouts/default.html b/_layouts/default.html
index 2d9be07..3be93ca 100644
--- a/_layouts/default.html
+++ b/_layouts/default.html
@@ -4,3 +4,9 @@ theme :
 ---
+
+<head>
+...
+<link href="/assets/css/syntax.css" rel="stylesheet">
+...
+</head>
```

# 贴图

使用以下语法可以贴图，记得设置相应路径即可。图是`蓝风一梦`，谢谢。

```
![](/Pictures/20141010_markdown.jpg)
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


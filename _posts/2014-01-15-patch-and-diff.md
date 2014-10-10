---
layout: post
title: "patch and diff"
category: linux
tags: [patch, diff]
---
{% include JB/setup %}

**[The Ten Minute Guide to diff and patch](http://jungels.net/articles/diff-patch-ten-minutes.html)**

# 对于文件

```bash
diff -u original.c new.c > original.patch
patch original.c < original.patch
```

# 对于文件夹

{% highlight bash %}
diff -rupN original/ new/ > original.patch
patch -Np1 < original.patch
{% endhighlight %}

## 在[github](http://stackoverflow.com/questions/9980186/how-to-create-a-patch-for-a-whole-directory-to-update-it) 有人有不同的方法来处理


{% highlight bash %}
diff -ruN orig/ new/ > file.patch
# -r == recursive, so do subdirectories
# -u == unified style, if your system lacks it or if recipient may not have it, use "-c"
# -N == treat absent files as empty

patch -s -p0 < file.patch
# -s == silent except errors
# -p0 == needed to find the proper folder
{% endhighlight %}

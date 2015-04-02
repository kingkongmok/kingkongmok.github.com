---
layout: post
title: "bash将结果重定向指向多个文件"
category: linux
tags: [tee]
---
{% include JB/setup %}

### [redirect output to multiple log files](http://unix.stackexchange.com/questions/41246/how-to-redirect-output-to-multiple-log-files)

```
echo test | tee file1 file2 file3
```

---
layout: post
title: "find command"
category: bash
tags: [find, printf, date]
---

## printf

[这里](http://cygwin.com/ml/cygwin/2005-01/msg00672.html) 有帖子提供find的bug，并给出一个很好的shell来测试printf的时间戳。

```
$ for fmt in H I k l p Z M S @ a A b h B m d w j U W Y y r T X c D x +
> do echo "$fmt: `find /etc/passwd -printf \"%T$fmt\"`"
> done
H: 15
I: 03
k: 15
l:  3
p: PM
Z: EDT
M: 36
S: 42
@: 1097523402
a: Mon
A: Monday
b: Oct
h: Oct
B: October
m: 10
d: 11
w: 1
j: 285
U: 41
W: 41
Y: 2004
y: 04
r: 1097523402            time, 12-hour (hh:mm:ss [AP]M)
T: 1097523402            time, 24-hour (hh:mm:ss)
X: 15:36:42
c: Mon Oct 11 15:36:42 2004
D: 1097523402            date (mm/dd/yy)
x: Mon Oct 11 2004
+: +                     Date and time, separated by '+'
```

非常好用呢。

### date

[这里](https://stackoverflow.com/questions/158044/how-to-use-find-to-search-for-files-created-on-a-specific-date/158235#158235)介绍了如何查找特定日子的文件

Example: To find all files modified on the 7th of June, 2006:

```bash
$ find . -type f -newermt 2007-06-07 ! -newermt 2007-06-08
```

To find all files accessed on the 29th of september, 2008:

```bash
$ find . -type f -newerat 2008-09-29 ! -newerat 2008-09-30
```

Or, files which had their permission changed on the same day:

```bash
$ find . -type f -newerct 2008-09-29 ! -newerct 2008-09-30
```

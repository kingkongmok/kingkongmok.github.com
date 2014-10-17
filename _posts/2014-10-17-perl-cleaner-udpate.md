---
layout: post
title: "perl cleaner udpate"
category: linux
tags: [perl, update]
---
{% include JB/setup %}

[Perl/perl-cleaner](http://wiki.gentoo.org/wiki/Project:Perl/perl-cleaner)可以在perl升级后那些使用旧版本libperl.so的binary。用于刚刚更系perl后没有给相应软件做ebuild的情况.

```
app-admin/perl-cleaner is a tool that cleans up old perl installations, attempting to emerge --oneshot packages left over from a perl upgrade, as well as any packages that linked against the old version of libperl.so.
```

可以直接上来就运行这个：

```bash
# perl-cleaner all
```

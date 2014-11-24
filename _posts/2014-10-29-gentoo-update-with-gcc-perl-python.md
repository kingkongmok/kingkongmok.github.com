---
layout: post
title: "gentoo升级的时候涉及到gcc，perl和python的处理方法"
category: linux
tags: [gcc-config, emerge, update, perl, python]
---
{% include JB/setup %}

### 处理方法

其实要多注意`eselect news`, 但这个似乎不会自动mail或者有什么git发布，需继续了解。

### gcc-config

* gcc升级后有可能会导致gcc profile不对，编译失败

["media-libs/lcms-2.6-r1" STDOUT](https://bpaste.net/show/7ef0633bcf7f)

["media-libs/lcms-2.6-r1" emerge info](https://bpaste.net/show/1d6aed089d24)

### 运行[gcc-config](http://wiki.gentoo.org/wiki/Upgrading_GCC)解决

```bash
kk@ins14 ~ $ sudo gcc-config -l
 * gcc-config: Active gcc profile is invalid!

  [1] x86_64-pc-linux-gnu-4.8.3
  kk@ins14 ~ $ sudo gcc-config 1
   * Switching native-compiler to x86_64-pc-linux-gnu-4.8.3 ...
   >>> Regenerating /etc/ld.so.cache...                                                                                 [ ok ]

    * If you intend to use the gcc from the new profile in an already
     * running shell, please remember to do:

      *   . /etc/profile
```

终结来说，需要手册上perl和python两个升级后的处理脚本遇到GCC升级，还得设置gcc-config

### perl-cleaner

[Perl/perl-cleaner](http://wiki.gentoo.org/wiki/Project:Perl/perl-cleaner)可以在perl升级后那些使用旧版本libperl.so的binary。用于刚刚更系perl后没有给相应软件做ebuild的情况.

```
app-admin/perl-cleaner is a tool that cleans up old perl installations, attempting to emerge --oneshot packages left over from a perl upgrade, as well as any packages that linked against the old version of libperl.so.
```

可以直接上来就运行这个：

```bash
# perl-cleaner all
```

### PYTHON_TARGETS

根据eselect news的提示，如果需要更新`PYTHON_TARGETS`，需要重新编译所有的`python libraries`

```
Once the changes have taken place, a world update should take care of
reinstalling any python libraries you have installed. You should also
switch your default python3 interpreter using eselect python.

For example:

eselect python set --python3 python3.4
emerge -uDv --changed-use @world
```

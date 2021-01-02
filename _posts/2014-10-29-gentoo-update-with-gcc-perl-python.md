---
layout: post
title: "gentoo升级的时候涉及到gcc，perl和python的处理方法"
category: linux
tags: [gcc-config, emerge, update, perl, python]
---

### 处理方法

其实要多注意`eselect news`, 但这个似乎不会自动mail或者有什么git发布，需继续了解。


### gcc-config

. gcc升级后有可能会导致gcc profile不对，编译失败

["media-libs/lcms-2.6-r1" STDOUT](https://bpaste.net/show/7ef0633bcf7f)

["media-libs/lcms-2.6-r1" emerge info](https://bpaste.net/show/1d6aed089d24)

### 运行[gcc-config](http://wiki.gentoo.org/wiki/Upgrading_GCC)解决

```bash
kk@ins14 ~ $ sudo gcc-config -l
         . /etc/profile
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

### [update all python packages with pip](https://stackoverflow.com/questions/2720014/how-to-upgrade-all-python-packages-with-pip)

```
pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install --user

```


### [删除多余的包](https://wiki.gentoo.org/wiki/Knowledge_Base:Remove_obsoleted_distfiles)

. The app-portage/gentoolkit package provides an application called eclean-dist which supports, among other strategies, the following clean-up activities.

. Running eclean-dist will remove the source code archives that do not belong to any available ebuild anymore. This is a safe approach since these sources are very unlikely to be needed again (most of these archives are of old ebuilds that have since been removed from the Portage tree).

```
#eclean-dist

```

. The --destructive option can be added to make eclean-dist remove the source code archives that do not belong to an installed ebuild. This will remove many more sources, but is still not be that troublesome since the source code archives of installed ebuilds remain available in case a rebuild is needed.

```
#eclean-dist --destructive
```

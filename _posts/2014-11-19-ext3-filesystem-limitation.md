---
layout: post
title: "ext3文件系统的使用局限"
category: linux
tags: [filesystem, ext3]
---
{% include JB/setup %}

在真实案例中有出现过多文件夹导致无法新建的情况

### 原因

根据[ext3 wiki](http://en.wikipedia.org/wiki/Ext4#cite_note-1)，ext3中文件夹有链接32000的限制，具体测试环境如下：

```
$ pwd
/tmp/test/testFolder

$ df
Filesystem     1K-blocks     Used Available Use% Mounted on
/dev/sda1       28768380 16921916  10362076  63% /
udev               10240        4     10236   1% /dev
tmpfs             102428      444    101984   1% /run
shm               512128        0    512128   0% /dev/shm
cgroup_root        10240        0     10240   0% /sys/fs/cgroup
/dev/sdb         8125880   157880   7548572   3% /tmp/test

$ sudo file -s /dev/sdb
/dev/sdb: Linux rev 1.0 ext3 filesystem data, UUID=670f00f1-cddc-409d-b326-c1e24a87174b (needs journal recovery) (large files)

$ for i in `seq -w 32000`; do mkdir $i; done

mkdir: cannot create directory ‘31999’: Too many links
mkdir: cannot create directory ‘32000’: Too many links
```

分析结果：

* 文件夹链接不能超过32000个，所以***.***, ***..***, ***00001~31998***后无法再新建文件夹
* 虽然文件夹能影响inum数量，但inum和blocks有关和分区大小成正比，所以在其他文件夹依然可以新建文件夹。
* 可以通过***df -i***来判断inum是否满。
* ext4可以做超过32000的单目录链接数，具体看[ext4 wiki](http://en.wikipedia.org/wiki/Ext4).


---
layout: post
title: "lvm"
category: linux
tags: [lvm]
---

## [lvm practise](http://hi.baidu.com/storymedia/blog/item/1d01cbf86a2e7d03d9f9fdd0.html)


## 基础操作

### 1.准备工作

```
lvmdiskscan #查看磁盘情况(包括虚拟磁盘)
mkdir /disk
```

### 2.创造块设备

```
dd if=/dev/zero of=/disk/hda bs=1M count=100
dd if=/dev/zero of=/disk/hdb bs=1M count=100
losetup /dev/loop0 /disk/hda
losetup /dev/loop1 /disk/hdb
```

### lvm 操作步骤

```
fdisk -l
3.物理卷
pvcreate /dev/loop{0,1} #初始化物理卷
pvscan #扫描物理卷
pvdisplay #查看物理卷信息
```

### 4.卷组

```
vgscan #扫描卷组
vgdisplay #查看卷组大小
vgcreate vgloop01 /dev/loop{0,1} #创建卷组
```

### 5.创建逻辑卷

```
lvcreate -L 20m -n lvloop01 vgloop01 #创建逻辑卷命名为lvloop01 大小20M
lvscan #扫描逻辑卷
lvdisplay #显示逻辑卷信息
```

### 6.格式化和挂载

```
mkfs.ext3 /dev/vgloop01/lvloop01 #格式化逻辑卷
mount /dev/vgloop01/lvloop01 /disk/lvm #挂载
df -h #查看当前磁盘情况
```

## 高级操作

### ==========增加=============

```
# lv增加30M存储
lvextend -L +30M /dev/vgloop01/lvloop01 
# lv增加所有vg空余存储
#lvextend -l 100%FREE /dev/vgloop01/lvloop01
lvextend -l +100%FREE /dev/vgloop01/lvloop01

# ext filesystem
e2fsck -f /dev/vgloop01/lvloop01 
# xfs filesystem
xfs_growfs /dev/dm-0

lvdisplay 
resize2fs /dev/vgloop01/lvloop01 50M

# 如果提示  exfsck lv_root is mounted.  e2fsck: Cannot continue, aborting.
resize2fs /dev/vg/lv_root
```

### ==========减小============

```
umount /disk/lvm/
e2fsck -f /dev/vgloop01/lvloop01 
resize2fs /dev/vgloop01/lvloop01 20M
lvresize --size 20M /dev/vgloop01/lvloop01
lvdisplay
mount /dev/vgloop01/lvloop01 /disk/lvm/
```

### 2.增加pv

```
dd if=/dev/zero of=/disk/hdc bs=1M count=100
losetup /dev/loop2 /disk/hdc
losetup -a
pvcreate /dev/loop2
vgdisplay 
vgextend vgloop01 /dev/loop2
```

## 模拟磁盘损坏

### 1.准备数据文件

```
cp -R /boot/vmlinuz-2.6.18-92.el5 /disk/lvm/
md5sum /disk/lvm/vmlinuz-2.6.18-92.el5 
b3654261b1f775e81adfe33657f3b965 /disk/lvm/vmlinuz-2.6.18-92.el5
```

### 2.假设/dev/loop0 设备损坏

```
pvmove -n /dev/vgloop01/lvloop01 /dev/loop0 /dev/loop2 #将/disk/lvm 中的数据从 /dev/loop0 迁移至 /dev/loop2上
vgreduce vgloop01 /dev/loop0 #将/dev/loop0 从vgloop01 中移出来
```

### pvscan

```
PV /dev/loop1   VG vgloop01     lvm2 [96.00 MB / 96.00 MB free]
PV /dev/loop2   VG vgloop01     lvm2 [96.00 MB / 76.00 MB free]
PV /dev/loop0                   lvm2 [100.00 MB]
pvremove /dev/loop0
```

备注：新硬盘容量一定在大于旧硬盘中的数据容量，并且新旧硬盘必须在同一个VG中
PS:pvmove命令用来把使用的pv移动到其他空余的pv中，需要内核的dm_mirror的支持，然而2.6.22内核中的dm_mirror有bug，执行会出错，建议升级到6.2.23。

### lvm 删除

```
umount /disk/lvm
lvremove /dev/vgloop01/lvloop01
vgremove vgloop01
pvremove /dev/loop{0,1,2}

losetup -a
losetup -d /dev/loop0
losetup -d /dev/loop1
losetup -d /dev/loop2
```

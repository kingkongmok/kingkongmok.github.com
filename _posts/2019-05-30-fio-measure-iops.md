---
layout: post
title: "使用fio计量iops"
category: linux
tags: [linux, iops]
---

### [HOW TO MEASURE DISK PERFORMANCE IOPS WITH FIO IN LINUX](https://arstech.net/how-to-measure-disk-performance-iops-with-fio-in-linux/)

**install**

```
USE=aio emerge fio
```


**Random read/write performance**

```
fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=4G --readwrite=randrw --rwmixread=75
```

**option**

```
readwrite=str, rw=str
   Type of I/O pattern. Accepted values are:

      read   Sequential reads.

      write  Sequential writes.

      trim   Sequential trims (Linux block devices only).

      randread
	     Random reads.

      randwrite
	     Random writes.

      randtrim
	     Random trims (Linux block devices only).

      rw,readwrite
	     Sequential mixed reads and writes.

      randrw Random mixed reads and writes.

      trimwrite
	     Sequential trim+write sequences. Blocks will be trimmed first, then the same blocks will be written to.

```

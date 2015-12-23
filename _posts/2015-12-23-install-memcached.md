---
layout: post
title: "memcached"
category: linux
tags: [memcached, replication]
---
{% include JB/setup %}

***

### 安装

```
./configure --prefix=/home/appSys/yuanbao/memcached-1.4.24 --with-libevent=/home/appSys/yuanbao/libevent-2.0.22-stable --enable-64bit
```

***

### 带主从功能的[memcached-repcached](http://guodong810.blog.51cto.com/4046313/1338953)的安装

* configure
* 注意***--enable-replication***
* [download](http://sourceforge.net/projects/repcached/files/)

```
./configure --with-libevent=/home/appSys/yuanbao/libevent-2.0.22-stable --prefix=/home/appSys/yuanbao/memcached-1.2.8-repcached-2.2.1 --enable-replication --enable-64bit
```

* IOV_MAX undeclared error
* 修改memcached.c, 删除以下if，让IOV_MAX赋值

```
#if defined(__FreeBSD__) ||defined(__APPLE__)
# define IOV_MAX 1024
#endif
```

***

### ldd 的设置

看openssl的doc/openssl-shared.txt有介绍怎么处理：

```
If this directory is not in a standard system path for dynamic/shared
libraries, then you will have problems linking and executing
applications that use OpenSSL libraries UNLESS:
 
 * you link with static (archive) libraries.  If you are truly
   paranoid about security, you should use static libraries.
 * you use the GNU libtool code during linking
   (http://www.gnu.org/software/libtool/libtool.html)
 * you use pkg-config during linking (this requires that
   PKG_CONFIG_PATH includes the path to the OpenSSL shared
   library directory), and make use of -R or -rpath.
   (http://www.freedesktop.org/software/pkgconfig/)
 * you specify the system-wide link path via a command such
   as crle(1) on Solaris systems.
 * you add the OpenSSL shared library directory to /etc/ld.so.conf
   and run ldconfig(8) on Linux systems.
 * you define the LD_LIBRARY_PATH, LIBPATH, SHLIB_PATH (HP),
   DYLD_LIBRARY_PATH (MacOS X) or PATH (Cygwin and DJGPP)
   environment variable and add the OpenSSL shared library
   directory to it.
```

* 例如:

```
$ tail -2 .bash_profile
LD_LIBRARY_PATH=$HOME/libevent-2.0.22-stable/lib
export LD_LIBRARY_PATH
```

---
layout: post
title: "memcached"
category: linux
tags: [memcached, replication, install]
---

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

---


### replication

1.  第一个memcached

    ```
    su - yuanbao -c "/home/appSys/yuanbao/memcached/bin/memcached -d -t 6 -l 192.168.1.1 -p 2211 -m 500  -c 1024 -P /home/appSys/yuanbao/memcached/run/memcached.pid -x 192.168.1.2 -X 21212"
    ```

2.  第一个memcached

    ```
    su - yuanbao -c "/home/appSys/yuanbao/memcached/bin/memcached -d -t 6 -l 192.168.1.2 -p 2211 -m 500  -c 1024 -P /home/appSys/yuanbao/memcached/run/memcached.pid -x 192.168.1.1 -X 21212"
    ```


---

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

---

### telnet测试

[引用](http://www.journaldev.com/16/memcached-telnet-commands-with-example)


```
Pankaj:~ Pankaj$ telnet localhost 11111
Trying ::1...
Connected to localhost.
Escape character is '^]'.
set Test 0 100 10
JournalDev
STORED
get Test
VALUE Test 0 10
JournalDev
END
replace Test 0 100 4
Temp
STORED
get Test
VALUE Test 0 4
Temp
END
stats items
STAT items:1:number 1
STAT items:1:age 19
STAT items:1:evicted 0
STAT items:1:evicted_time 0
STAT items:1:outofmemory 0
STAT items:1:tailrepairs 0
END
flush_all
OK
get Test
END
version
VERSION 1.2.8
quit
Connection closed by foreign host.
Pankaj:~ Pankaj$
```



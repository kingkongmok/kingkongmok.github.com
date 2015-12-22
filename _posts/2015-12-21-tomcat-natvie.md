---
layout: post
title: "tomcat natvie的安装"
category: linux
tags: [tomcat, openssl, apr, tomcat-native]
---
{% include JB/setup %}

*****

### libtcnative 编译错误

```
 /usr/local/ssl/lib/libssl.a: could not read symbols: Bad value
 collect2: ld returned 1 exit status
 make[1]: *** [libtcnative-1.la] Error 1
 make[1]: Leaving directory
```

#### 解决方法：

when configuring openssl, you must run: 
 ./config shared

#### shared

```
  shared        In addition to the usual static libraries, create shared
                libraries on platforms where it's supported.  See "Note on
                shared libraries" below.
```

*****

### tomcat-native 步骤

* 下载jdk-bin 并解压
* 安装openssl，需要shared参数
* 安装apr

```
cd tomcat-native-1.2.3-src/native/
 ./configure --prefix=/home/appSys/yuanbao/tomcat-native-1.2.3 --with-ssl=/home/appSys/yuanbao/openssl-1.0.2d --with-java-home=/home/appSys/yuanbao/jdk --with-apr=/home/appSys/yuanbao/apr-1.5.2
make
make install
```

*****

---
layout: post
title: "openssh的安装"
category: linux
tags: [openssh, openssl, sshd, compile, install]
---
{% include JB/setup %}

### error message

```
./configure --prefix=/usr/local/openssh-6.9p1

...

checking if openpty correctly handles controlling tty... yes
checking whether AI_NUMERICSERV is declared... yes
checking whether getpgrp requires zero arguments... yes
checking OpenSSL header version... 0090802f (OpenSSL 0.9.8e-rhel5 01 Jul 2008)
checking OpenSSL library version... configure: error: OpenSSL >= 0.9.8f required (have "0090802f (OpenSSL 0.9.8e-fips-rhel5 01 Jul 2008)")
```

* 在安装openssl后，错误依然存在：

```
./configure --with-ssl-dir=/usr/local/openssl-1.0.2d --prefix=/usr/local/openssh-6.9p1

...

checking OpenSSL header version... 0090802f (OpenSSL 0.9.8e-rhel5 01 Jul 2008)
checking OpenSSL library version... configure: error: OpenSSL >= 0.9.8f required (have "0090802f (OpenSSL 0.9.8e-fips-rhel5 01 Jul 2008)")
```

#### read INSTALL

``` 

LibreSSL/OpenSSL should be compiled as a position-independent library
(i.e. with -fPIC) otherwise OpenSSH will not be able to link with it.
If you must use a non-position-independent libcrypto, then you may need
to configure OpenSSH --without-pie.

```

### 解决方法 

```
./configure --with-ssl-dir=/usr/local/openssl-1.0.2d --prefix=/usr/local/openssh-6.9p1 --without-pie
```

安装成功。

### 测试

本机验证服务是否报错：

```
/usr/local/openssh-6.9p1/sbin/sshd -t -f /usr/local/openssh-6.9p1/etc/sshd_config -d
```

运行后检查是否监听端口：

```
ss -ntlp | grep sshd
```

客户端debug观察运行的情况：

```
ssh -vvv HOST -p PORT
```

### 自动脚本

* sysvinit 省略
* systemd

```
[Unit]
Description=OpenSSH server daemon
After=syslog.target network.target auditd.service

[Service]
ExecStartPre=/usr/bin/ssh-keygen -A
ExecStart=/usr/sbin/sshd -D -e
ExecReload=/bin/kill -HUP $MAINPID

[Install]
WantedBy=multi-user.target
```

```
sudo systemctl status sshd
● sshd.service - OpenSSH server daemon
   Loaded: loaded (/usr/lib64/systemd/system/sshd.service; enabled; vendor preset: enabled)
   Active: active (running) since Tue 2015-07-28 14:31:52 CST; 2h 7min ago
  Process: 15110 ExecStartPre=/usr/bin/ssh-keygen -A (code=exited, status=0/SUCCESS)
 Main PID: 15112 (sshd)
   CGroup: /system.slice/sshd.service
           └─15112 /usr/sbin/sshd -D -e

Jul 28 14:31:52 ins14 sshd[15112]: Server listening on 0.0.0.0 port 22.
Jul 28 14:31:52 ins14 sshd[15112]: Server listening on :: port 22.
Jul 28 14:32:15 ins14 sshd[15112]: Bad protocol version identification '\377\364\377\375\006\377\364\377\375\006\3... 44199
Jul 28 14:34:15 ins14 sshd[15112]: Bad protocol version identification '\377\364\377\375\006' from ::1 port 44200
Jul 28 14:43:16 ins14 sshd[15112]: Accepted keyboard-interactive/pam for kk from 10.0.2.2 port 61680 ssh2
Jul 28 14:43:16 ins14 sshd[15442]: pam_unix(sshd:session): session opened for user kk by (uid=0)
Jul 28 15:30:34 ins14 sshd[15112]: Received disconnect from 10.0.2.2: 0:
Jul 28 15:30:34 ins14 sshd[15112]: Disconnected from 10.0.2.2
Jul 28 15:52:25 ins14 sshd[15112]: Accepted keyboard-interactive/pam for kk from 10.0.2.2 port 62788 ssh2
Jul 28 15:52:25 ins14 sshd[15708]: pam_unix(sshd:session): session opened for user kk by (uid=0)
Hint: Some lines were ellipsized, use -l to show in full.
```
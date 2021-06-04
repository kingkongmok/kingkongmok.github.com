---
layout: post
title: "openssh的安装"
category: linux
tags: [openssh, openssl, sshd, compile, install]
---

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

---


### with openssl

```
# openssl
./config --prefix=/usr/local/openssl-1.1.1g
make -j8 && make install
echo /usr/local/openssl-1.1.1g/lib >> /etc/ld.so.conf
ldconfig
/usr/local/openssl-1.1.1g/bin/openssl version -a


# openssh
patch --strip=1 < 0001-seccomp-Allow-clock_nanosleep-in-sandbox.patch

yum install -y gcc make wget openssl-devel krb5-devel pam-devel libX11-devel xmkmf libXt-devel pam-devel
./configure --with-pam --prefix=/usr/local/openssh-8.4p1 --sysconfdir=/etc/ssh  --with-md5-passwords --with-tcp-wrappers --with-ssl-dir=/usr/local/openssl-1.1.1g
make && make install
```

---


```

# openssl install

./config --prefix=/usr/local/openssl-1.1.1k
make && make install


# make
yum install -y gcc make wget openssl-devel krb5-devel pam-devel libX11-devel xmkmf libXt-devel pam-devel
./configure --with-pam --prefix=/usr/local/openssh-8.6p1 --sysconfdir=/etc/ssh  --with-md5-passwords --with-tcp-wrappers --with-ssl-dir=/usr/local/openssl-1.1.1k --without-pie
make && make install

# install
yum install -y telnet-server
sed -i 's/disable.*yes/disable = no/' /etc/xinetd.d/telnet
chkconfig xinetd off
service xinetd start

cp -a /etc/init.d/sshd /etc/init.d/sshd-local
chkconfig --add sshd-local
chkconfig sshd off
sed -i 's#SSHD=/usr/sbin/sshd#SSHD=/usr/local/openssh-local/sbin/sshd#' /etc/init.d/sshd-local
chkconfig --list | grep -P "sshd|xinetd"
sed -i.8.4p1.bak 's/^GSSAPIAuthentication/#GSSAPIAuthentication/; s/^GSSAPICleanupCredentials/#GSSAPICleanupCredentials/' /etc/ssh/sshd_config
service sshd stop
service sshd-local start
ps -ef |grep sshd

service xinetd stop
```

---

## disable aes256-cbc and aes128-cbc


```

cp -a /etc/crypto-policies/back-ends/opensshserver.config{,.orig}
vim /etc/crypto-policies/back-ends/opensshserver.config
删除aes256-cbc
删除aes128-cbc


systemctl status sshd | grep -P "aes256-cbc|aes128-cbc"
```

---

### docker sshd not work

```
/usr/sbin/sshd -D -d
debug1: sshd version OpenSSH_7.4, OpenSSL 1.0.2k-fips  26 Jan 2017
debug1: key_load_private: No such file or directory
debug1: key_load_public: No such file or directory
Could not load host key: /etc/ssh/ssh_host_rsa_key
debug1: key_load_private: No such file or directory
debug1: key_load_public: No such file or directory
Could not load host key: /etc/ssh/ssh_host_dsa_key
debug1: key_load_private: No such file or directory
debug1: key_load_public: No such file or directory
Could not load host key: /etc/ssh/ssh_host_ecdsa_key
debug1: key_load_private: No such file or directory
debug1: key_load_public: No such file or directory
Could not load host key: /etc/ssh/ssh_host_ed25519_key
sshd: no hostkeys available -- exiting.


ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
ssh-keygen -t ecdsa -f  /etc/ssh/ssh_host_ecdsa_key
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key


```


---




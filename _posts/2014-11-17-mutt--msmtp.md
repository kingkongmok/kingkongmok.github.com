---
layout: post
title: "mutt & msmtp 在Centos5上的编译安装"
category: linux
tags: [mutt, msmtp, centos]
---
{% include JB/setup %}

#### packages

```
http://colocrossing.dl.sourceforge.net/project/msmtp/msmtp/1.4.18/msmtp-1.4.18.tar.bz2
http://softlayer-dal.dl.sourceforge.net/project/mutt/mutt/mutt-1.5.23.tar.gz

$ md5sum /usr/local/src/*

11f5b6a3eeba1afa1257fe93c9f26bff  /usr/local/src/mutt-1.5.23.tar.gz
74f80b41c058a0ee34819d6bf5ff3b1a  /usr/local/src/msmtp-1.4.18.tar.bz2
```

#### msmtp dependency

```
# yum deplist msmtp | grep dependency | perl -lnae 'print $1 if $F[1] =~ /(.*?)\(.*/'
libgsasl.so.7
libc.so.6
libdl.so.2
libidn.so.11
libz.so.1
rtld
libglib-2.0.so.0
libcrypto.so.6
libgnome-keyring.so.0
libssl.so.6
```

#### msmtp install

```
# yum install gnutls-devel.x86_64 libgsasl-devel.x86_64 libidn-devel.x86_64
# cd /usr/local/src/
# tar xjpf msmtp-1.4.18.tar.bz2
# cd msmtp-1.4.18
# ./configure --exec-prefix=/usr/local/msmtp-1.4.18 --with-libgsasl --with-libidn --with-gnu-ld
# make && make install 
# ln -s ../msmtp-1.4.18/bin/msmtp ../bin/
```

#### msmtp config

```
# cat > ~/.msmtprc << EOF
account default
host smtp.163.com
from kk_richinfo@163.com
auth login
port 25
user kk_richinfo@163.com
password 1q2w3e4r
tls off
syslog on
EOF

# chmod 400 ~/.msmtprc
```

### mutt dependency

```
# yum deplist mutt | grep dependency | perl -lnae 'print $1 if $F[1] =~ /(.*?)\(.*/'
libc.so.6
libgssapi_krb5.so.2
libc.so.6
libc.so.6
libc.so.6
libkrb5.so.3
libcom_err.so.2
rtld
config
libgssapi_krb5.so.2
libcrypto.so.6
libsasl2.so.2
libssl.so.6
libncursesw.so.5
libk5crypto.so.3
libc.so.6
```

#### mutt install

```
# yum install ncurses-devel.x86_64
# cd /usr/local/src/
# tar xzpf mutt-1.5.23.tar.gz
# cd mutt-1.5.23
# ./configure --prefix=/usr/local/mutt-1.5.23 --enable-pop --enable-imap --enable-smtp --enable-mailtool --with-regex 
# make && make install 
# ln -s ../mutt-1.5.23/bin/mutt ../bin/
```


#### mutt config

```
# cat >> ~/.muttrc << EOF
set sendmail="/usr/local/bin/msmtp"
set use_from=yes
set from=kk_richinfo@163.com
set envelope_from=yes
EOF
```

### test example

```bash
cat ~/.bashrc | /usr/local/bin/mutt -e 'set content_type="text/html"' moqingqiang@richinfo.cn -s "testmail"
```

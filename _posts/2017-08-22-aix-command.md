---
title: "aix command"
layout: post
category: linux
---

## [How to check which shell am I using?](https://askubuntu.com/questions/590899/how-to-check-which-shell-am-i-using)

```
$ echo $0
-ksh
```

---

[bash, ksh ,zsh下使用下面的命令在emacs
風格和vi風格切換](http://www.cnblogs.com/zhouhbing/p/4275699.html)

```
set -o vi
# set -o emacs
```

---

### 登陆失败

I try different account to login system, grant sudo right to this account,
change the password using pwdadm and passwd, but when I login with putty, found
that Access denied. When I run su - user, found “3004-303 There have been too
many unsuccessful login attempts; please see the system administrator”, found
the root cause, after google, easy two steps can sovle it.

```
- /usr/sbin/lsuser -a unsuccessful_login_count user
- /usr/bin/chsec -f /etc/security/lastlog -a unsuccessful_login_count=0 -s user
```


---


### netstat command

in linux

```
netstat -nltp | grep 22
```

in aix

```
netstat -Aan|grep 22
```


---

### 查看配置 prtconf

```
prtconf |grep disk
```

---

### syslog


config file **/etc/syslog.conf**, 注意中间的是tab

```
*.emerg;*.alert;*.crit;*.warning;*.err;*.notice;*.info  @172.16.40.73
```

```
# check syslog
ps -ef|grep syslogd

# stop syslog
stopsrc -s syslogd

# start syslog
startsrc -s syslogd

# insert syslog
logger "test message"
```

---

## [https://sysaix.com/aix-command-vs-linux-commands](https://sysaix.com/aix-command-vs-linux-commands)


---

```
lsblk
lsdev -Cc.disk
```

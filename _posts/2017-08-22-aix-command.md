---
title: "aix command"
layout: post
category: linux
---

## [How to check which shell am I
using?](https://askubuntu.com/questions/590899/how-to-check-which-shell-am-i-using)

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

I try different account to login system, grant sudo right to this account,
change the password using pwdadm and passwd, but when I login with putty, found
that Access denied. When I run su - user, found “3004-303 There have been too
many unsuccessful login attempts; please see the system administrator”, found
the root cause, after google, easy two steps can sovle it.

```
- /usr/sbin/lsuser -a unsuccessful_login_count user
- /usr/bin/chsec -f /etc/security/lastlog -a unsuccessful_login_count=0 -s user
```

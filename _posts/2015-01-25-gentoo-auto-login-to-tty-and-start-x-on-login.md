---
layout: post
title: "gentoo auto login to tty and start X on login"
category: linux
tags: [gentoo, tty, autologin]
---

每天启动后需要装xdm中输入帐号密码非常不方便，xdm不支持autologin，gentoo建议的方法是tty auto login + start X while tty。

#### [tty auto login](http://wiki.gentoo.org/wiki/Automatic_login_to_virtual_console)

```
$ diff -u /etc/inittab linux/etc/inittab--- /etc/inittab    2015-01-25 22:38:21.986660861 +0800
+++ linux/etc/inittab   2015-01-25 22:38:49.096091014 +0800
@@ -36,8 +36,7 @@
 su1:S:wait:/sbin/sulogin
 
 # TERMINALS
-#c1:12345:respawn:/sbin/agetty 38400 tty1 linux
-c1:12345:respawn:/sbin/agetty -a kk --noclear 38400 tty1 linux
+c1:12345:respawn:/sbin/agetty 38400 tty1 linux
 c2:2345:respawn:/sbin/agetty 38400 tty2 linux
 c3:2345:respawn:/sbin/agetty 38400 tty3 linux
 c4:2345:respawn:/sbin/agetty 38400 tty4 linux
```

#### [start X while tty](http://wiki.gentoo.org/wiki/Start_X_on_login)

```
$ git diff | cat
diff --git a/linux/home/kk/.bashrc b/linux/home/kk/.bashrc
index 4054fba..954d954 100644
--- a/linux/home/kk/.bashrc
+++ b/linux/home/kk/.bashrc
@@ -97,3 +97,9 @@ alias grep='grep --perl-regexp --color=auto'
 alias g='grep --perl-regexp --color=auto'
 alias mv='mv -i'
 alias cp='cp -i'
+
+#Starting X11 on console login
+#if [[ ! ${DISPLAY} && ${XDG_VTNR} == 8 ]]; then
+#    exec startx
+#fi
+[[ $(tty) = "/dev/tty1" ]] && exec startx
```

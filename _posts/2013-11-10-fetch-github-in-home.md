---
layout: post
title: "fetch github in home 如何设置git"
category: web
tags: [github, pull, ssh, clone, https]
---

##设置

**不想使用https，就可以进入相应的文件夹，然后设置使用ssh(git://)来和remote联系,当然必须先设置id_rsa.pub**

```
kk@t510:~/workplace/kingkongmok.github.com$ git config --global user.name "kingkongmok"
kk@t510:~/workplace/kingkongmok.github.com$ git config --global user.email "kingkongmok@gmail.com"
kk@t510:~/workplace/kingkongmok.github.com$ git remote set-url origin git@github.com:kingkongmok/kingkongmok.github.com 
kk@t510:~/workplace/kingkongmok.github.com$ git pull
Warning: Permanently added the RSA host key for IP address '192.30.252.130' to the list of known hosts.
Already up-to-date.
```

**其实上面的方法没有验证过……, clone的方法倒是比较稳健**

```
kk@t510:~/workplace$ git clone git://github.com/kingkongmok/perl.git perl
Cloning into 'perl'...
remote: Counting objects: 88, done.
remote: Compressing objects: 100% (56/56), done.
remote: Total 88 (delta 34), reused 70 (delta 24)
Receiving objects: 100% (88/88), 23.02 KiB | 7 KiB/s, done.
Resolving deltas: 100% (34/34), done.
kk@t510:~/workplace/perl$ git remote set-url origin git@github.com:kingkongmok/perl.git
```

###  同步 git文件夹和home文件夹

实际上git的文件夹是在```~/workspace/kingkongmok.github.com```, 我需要同步的时候先进去，同步除了.vim外的其他文件。

```
cd workspace/kingkongmok.github.com/linux/home/kk/ && \
find  . -type f -printf "%P\n" | grep -v ^.vim | xargs -ri ln -fv {} ~/{}
```



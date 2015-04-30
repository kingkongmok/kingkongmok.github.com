---
layout: post
title: "安装perl和使用cpan配置模块"
category: perl
tags: [perl, cpan, local]
---
{% include JB/setup %}

### [perl install](https://www.perl.org/get.html)

这里我们解压到***/usr/local/src***, 保留安装包是一个好习惯。

```
tar xzpf perl-5.20.2.tar.gz -C /usr/local/src/perl-5.20.2
cd /usr/local/src/perl-5.20.2
```

查看README文件，可知PREFIX的方法如下：

```
  ./Configure -des -Dprefix=/usr/local/perl-5.20.2
  make test
  make install
```

### [cpan安装](http://stackoverflow.com/questions/540640/how-can-i-install-a-cpan-module-into-a-local-directory) 

在上面这个方法如不仔细看可能会出异常，需要做一些修改。主要区别还是需要按照cpan的向导去做，其中，直接输入cpan后，会提示自动完成init。如果自动init异常，则需要手动调整:

配置好的MyConfig.pm也和[ubuntu配置](http://askubuntu.com/questions/209615/change-cpan-install-directory)有不同，有关键字不一样。

#### ubuntu way

```
'makepl_arg' => q[INSTALL_BASE=/usr/local/perl-5.20.2],
'mbuildpl_arg' => q[--install_base=/usr/local/perl-5.20.2],

```

#### cpan init way

```
'makepl_arg' => q[INSTALLDIRS=site],
'mbuildpl_arg' => q[--installdirs site],
```

经测试，使用cpan init的方式可用，ubuntu介绍的方式不可用。

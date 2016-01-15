---
layout: post
title: "Perl的模块安装和cpan的使用"
category: perl
tags: [perl, cpan, local, modules, install]
---
{% include JB/setup %}

## cpan


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

---

## compile install

###  make

+ **Makefile.Pl** 相当于 **configure** 文件
+ 默认的prefix是**/usr**
+ 参数LIB和PREFIX的关系看[这里](http://www.perlmonks.org/?node_id=564720)

1. PREFIX

    > This will install all files in the module under your home directory, with man pages and libraries going into an appropriate place (usually ~/man and ~/lib).

2. LIB

    > This will install the module's architecture-independent files into ~/lib, the architecture-dependent files into ~/lib/$archname.


---

### example


```
perl ./Makefile.PL PREFIX=~/perl5lib LIB=~/perl5lib
make 
make test
make install
```
---

### .bash_profile for $PERL5LIB

```
if [ -z "$PERL5LIB" ]
then
        # If PERL5LIB wasn't previously defined, set it...
        PERL5LIB=~/perl5lib
else
        # ...otherwise, extend it.
        PERL5LIB=$PERL5LIB:~/perl5lib
fi


export PERL5LIB 
```

---

### 模块更新

[引用](http://stackoverflow.com/questions/3727795/how-do-i-update-all-my-cpan-module-to-their-latest-versions)

```
perl -MCPAN -e "upgrade /(.\*)/"
```

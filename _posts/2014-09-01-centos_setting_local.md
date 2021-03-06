---
layout: post
title: "centos_setting_local Centos用户的环境配置"
category: linux
tags: [centos, settings, local]
---

centos的一些配置和常用环境稍稍不同，需要注意。

## color shell

可以先设置一下colorshell。这个是绿色的

```
echo "PS1='\[\033[02;32m\]\u@\H:\[\033[02;36m\]\w\$\[\033[00m\] '" >> ~/.bashrc
```

如果需要设置一下前面为红色,参考[arch](https://wiki.archlinux.org/index.php/Color_Bash_Prompt)的设置
history也设置一下

```
PS1='\[\e[0;31m\]\u\[\e[m\] \[\e[1;36m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[1;37m\]'
LS_COLORS=$LS_COLORS:'di=1;36:ln=36'
```

---

### ~/.bashrc

```

PS1='\[\e[0;31m\]\u@\h\[\e[m\] \[\e[1;36m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[1;37m\]'
LS_COLORS=$LS_COLORS:'di=1;36:ln=36'
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend
HISTSIZE=30000
HISTFILESIZE=300000
HISTTIMEFORMAT="%F %T "

LANG="en_US.utf8"
LC_ALL="en_US.utf8"
export EDITOR="vim"

# User specific aliases and functions

export PATH=$PATH:~/bin/:/usr/local/sbin/:/usr/sbin/:/sbin/
```

---

## ~/.vimrc

```
if has("syntax")
  syntax on
endif
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
set showcmd		" Show (partial) command in status line.
set showmatch		" Show matching brackets.
set ignorecase		" Do case insensitive matching
set smartcase		" Do smart case matching
set incsearch		" Incremental search
set autowrite		" Automatically save before commands like :next and :make
set hidden             " Hide buffers when they are abandoned
set nu
set hls
set background=dark
hi StatusLine ctermfg=39 ctermbg=239 cterm=None
hi StatusLineNC ctermfg=39 ctermbg=239 cterm=None
hi VertSplit ctermfg=39 ctermbg=239 cterm=None
if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif
:filetype plugin on
highlight link MRUFileName LineNr
let MRU_Max_Entries = 1000
if has("autocmd")
  filetype plugin indent on
endif
set smartindent
set expandtab
set visualbell t_vb=
set t_Co=256
set autoindent
:nnoremap <F8> :setl si paste! si paste?<CR> 
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
set wrap
set linebreak
set nolist  " list disables linebreak
set complete-=i
set tabstop=8
set softtabstop=4
set shiftwidth=4
let &colorcolumn=join(range(81,999),",")                                        
let &colorcolumn="80,".join(range(400,999),",")     
highlight Comment ctermfg=green
```

---

如果需要设置用户后面有主机名，很简单修改一下\u@\h
history也设置一下
```
PS1='\[\e[0;31m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[1;37m\]'
PS1='\[\e[0;31m\]\u@\h\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[1;37m\]'
LS_COLORS=$LS_COLORS:'di=1;36:ln=36'
```




刚刚开始的时候，觉得curl的 -I 和一般不同，但man能找到相应设置，这个需要另外测试一下。
```
$ curl --version
curl 7.15.5 (x86_64-redhat-linux-gnu) libcurl/7.15.5 OpenSSL/0.9.8b zlib/1.2.3 libidn/0.6.5
Protocols: tftp ftp telnet dict ldap http file https ftps 
Features: GSS-Negotiate IDN IPv6 Largefile NTLM SSL libz
```

幸好grep和sed感觉差不多，awk不会用自动忽略。
```
$ grep --version
grep (GNU grep) 2.5.1

Copyright 1988, 1992-1999, 2000, 2001 Free Software Foundation, Inc.
This is free software; see the source for copying conditions. There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

```

perl 感觉好像没问题，但注意pm是不能用了。自己的pm也懒得导。
```
$ perl -V
Summary of my perl5 (revision 5 version 8 subversion 8) configuration:
  Platform:
    osname=linux, osvers=2.6.18-274.12.1.el5, archname=x86_64-linux-thread-multi
    uname='linux x86-003.build.bos.redhat.com 2.6.18-274.12.1.el5 #1 smp tue nov 8 21:37:35 est 2011 x86_64 x86_64 x86_64 gnulinux '
    config_args='-des -Doptimize=-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic -Dversion=5.8.8 -Dmyhostname=localhost -Dperladmin=root@localhost -Dcc=gcc -Dcf_by=Red Hat, Inc. -Dinstallprefix=/usr -Dprefix=/usr -Dlibpth=/usr/local/lib64 /lib64 /usr/lib64 -Dprivlib=/usr/lib/perl5/5.8.8 -Dsitelib=/usr/lib/perl5/site_perl/5.8.8 -Dvendorlib=/usr/lib/perl5/vendor_perl/5.8.8 -Darchlib=/usr/lib64/perl5/5.8.8/x86_64-linux-thread-multi -Dsitearch=/usr/lib64/perl5/site_perl/5.8.8/x86_64-linux-thread-multi -Dvendorarch=/usr/lib64/perl5/vendor_perl/5.8.8/x86_64-linux-thread-multi -Darchname=x86_64-linux-thread-multi -Dvendorprefix=/usr -Dsiteprefix=/usr -Duseshrplib -Dusethreads -Duseithreads -Duselargefiles -Dd_dosuid -Dd_semctl_semun -Di_db -Ui_ndbm -Di_gdbm -Di_shadow -Di_syslog -Dman3ext=3pm -Duseperlio -Dinstallusrbinperl=n -Ubincompat5005 -Uversiononly -Dpager=/usr/bin/less -isr -Dd_gethostent_r_proto -Ud_endhostent_r_proto -Ud_sethostent_r_proto -Ud_endprotoent_r_proto -Ud_setprotoent_r_proto -Ud_endservent_r_proto -Ud_setservent_r_proto -Dinc_version_list=5.8.7 5.8.6 5.8.5 -Dscriptdir=/usr/bin'
    hint=recommended, useposix=true, d_sigaction=define
    usethreads=define use5005threads=undef useithreads=define usemultiplicity=define
    useperlio=define d_sfio=undef uselargefiles=define usesocks=undef
    use64bitint=define use64bitall=define uselongdouble=undef
    usemymalloc=n, bincompat5005=undef
  Compiler:
    cc='gcc', ccflags ='-D_REENTRANT -D_GNU_SOURCE -fno-strict-aliasing -pipe -Wdeclaration-after-statement -I/usr/local/include -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -I/usr/include/gdbm',
    optimize='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic',
    cppflags='-D_REENTRANT -D_GNU_SOURCE -fno-strict-aliasing -pipe -Wdeclaration-after-statement -I/usr/local/include -I/usr/include/gdbm'
    ccversion='', gccversion='4.1.2 20080704 (Red Hat 4.1.2-50)', gccosandvers=''
    intsize=4, longsize=8, ptrsize=8, doublesize=8, byteorder=12345678
    d_longlong=define, longlongsize=8, d_longdbl=define, longdblsize=16
    ivtype='long', ivsize=8, nvtype='double', nvsize=8, Off_t='off_t', lseeksize=8
    alignbytes=8, prototype=define
  Linker and Libraries:
    ld='gcc', ldflags =''
    libpth=/usr/local/lib64 /lib64 /usr/lib64
    libs=-lresolv -lnsl -lgdbm -ldb -ldl -lm -lcrypt -lutil -lpthread -lc
    perllibs=-lresolv -lnsl -ldl -lm -lcrypt -lutil -lpthread -lc
    libc=, so=so, useshrplib=true, libperl=libperl.so
    gnulibc_version='2.5'
  Dynamic Linking:
    dlsrc=dl_dlopen.xs, dlext=so, d_dlsymun=undef, ccdlflags='-Wl,-E -Wl,-rpath,/usr/lib64/perl5/5.8.8/x86_64-linux-thread-multi/CORE'
    cccdlflags='-fPIC', lddlflags='-shared -O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic'


Characteristics of this binary (from libperl): 
  Compile-time options: MULTIPLICITY PERL_IMPLICIT_CONTEXT
                        PERL_MALLOC_WRAP USE_64_BIT_ALL USE_64_BIT_INT
                        USE_ITHREADS USE_LARGE_FILES USE_PERLIO
                        USE_REENTRANT_API
  Built under linux
  Compiled at Dec 16 2011 08:20:05
  @INC:
    /usr/lib64/perl5/site_perl/5.8.8/x86_64-linux-thread-multi
    /usr/lib/perl5/site_perl/5.8.8
    /usr/lib/perl5/site_perl
    /usr/lib64/perl5/vendor_perl/5.8.8/x86_64-linux-thread-multi
    /usr/lib/perl5/vendor_perl/5.8.8
    /usr/lib/perl5/vendor_perl
    /usr/lib64/perl5/5.8.8/x86_64-linux-thread-multi
    /usr/lib/perl5/5.8.8
    .
```


---

### [force a CIFS connection to unmount](https://stackoverflow.com/questions/74626/how-do-you-force-a-cifs-connection-to-unmount)


```
umount -a -t cifs -l
```

---

### nfs set config without restart

```
exportfs -ra
```

--- 

### [SYSTEMD TARGETS](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/sect-managing_services_with_systemd-targets)

```
runlevel3.target, multi-user.target
runlevel5.target, graphical.target
```

```
# Viewing the Default Target
systemctl get-default
systemctl list-units --type target

# Changing the Default Target
sudo systemctl set-default multi-user.target

# Changing the Current Target
sudo systemctl isolate multi-user.target
```


---

### yum  centos-vault

```
# CentOS-Base.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the
# remarked out baseurl= line instead.
#
#

[base]
name=CentOS-6.10 - Base - mirrors.aliyun.com
failovermethod=priority
baseurl=https://mirrors.aliyun.com/centos-vault/6.10/os/$basearch/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-6

#released updates
[updates]
name=CentOS-6.10 - Updates - mirrors.aliyun.com
failovermethod=priority
baseurl=https://mirrors.aliyun.com/centos-vault/6.10/updates/$basearch/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-6

#additional packages that may be useful
[extras]
name=CentOS-6.10 - Extras - mirrors.aliyun.com
failovermethod=priority
baseurl=https://mirrors.aliyun.com/centos-vault/6.10/extras/$basearch/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-6

#additional packages that extend functionality of existing packages
[centos-vaultplus]
name=CentOS-6.10 - Plus - mirrors.aliyun.com
failovermethod=priority
baseurl=https://mirrors.aliyun.com/centos-vault/6.10/centos-vaultplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-6

#contrib - packages by Centos Users
[contrib]
name=CentOS-6.10 - Contrib - mirrors.aliyun.com
failovermethod=priority
baseurl=https://mirrors.aliyun.com/centos-vault/6.10/contrib/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-6
```

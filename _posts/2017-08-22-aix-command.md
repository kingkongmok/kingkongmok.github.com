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

---


## [LVM and VxVM](https://sort.veritas.com/public/documents/sf/5.0/aix/html/sf_migration/mg_ch_comdiffs_aix_sf2.html)


查看存储设备情况

```
# prtconf | grep disk
hdisk0            active            558         0           00..00..00..00..00
hdisk1            active            558         0           00..00..00..00..00
hdisk31           active            558         72          00..00..00..00..72
hdisk32           active            558         76          00..00..00..00..76
+ hdisk1           U78AA.001.WZSJKML-P2-D4                                       SAS Disk Drive (300000 MB)
+ hdisk31          U78AA.001.WZSJKML-P2-D1                                       SAS Disk Drive (300000 MB)
+ hdisk32          U78AA.001.WZSJKML-P2-D2                                       SAS Disk Drive (300000 MB)
+ hdisk0           U78AA.001.WZSJKML-P2-D3                                       SAS Disk Drive (300000 MB)
* hdisk14          U78AA.001.WZSJKML-P1-C4-T1-W20150080E5187ACC-LC000000000000   IBM MPIO DS5020 Array Disk
* hdisk3           U78AA.001.WZSJKML-P1-C3-T1-W20150080E5187ACC-L1000000000000   IBM MPIO DS5020 Array Disk
* hdisk4           U78AA.001.WZSJKML-P1-C3-T1-W20150080E5187ACC-L2000000000000   IBM MPIO DS5020 Array Disk
* hdisk5           U78AA.001.WZSJKML-P1-C3-T1-W20150080E5187ACC-L3000000000000   IBM MPIO DS5020 Array Disk
* hdisk6           U78AA.001.WZSJKML-P1-C3-T1-W20150080E5187ACC-L4000000000000   IBM MPIO DS5020 Array Disk
* hdisk7           U78AA.001.WZSJKML-P1-C3-T1-W20150080E5187ACC-L5000000000000   IBM MPIO DS5020 Array Disk
* hdisk8           U78AA.001.WZSJKML-P1-C3-T1-W20150080E5187ACC-L6000000000000   IBM MPIO DS5020 Array Disk
* hdisk9           U78AA.001.WZSJKML-P1-C3-T1-W20150080E5187ACC-L7000000000000   IBM MPIO DS5020 Array Disk

```

查看lvm情况

```
# lspv
hdisk2          none                                VeritasVolumes
hdisk3          none                                VeritasVolumes
hdisk4          none                                VeritasVolumes
hdisk5          none                                VeritasVolumes
hdisk6          none                                VeritasVolumes
hdisk7          none                                VeritasVolumes
hdisk8          none                                VeritasVolumes
hdisk9          none                                VeritasVolumes
hdisk10         none                                VeritasVolumes
hdisk11         none                                VeritasVolumes
hdisk12         none                                VeritasVolumes
hdisk13         none                                VeritasVolumes
hdisk14         none                                VeritasVolumes
hdisk15         none                                VeritasVolumes
hdisk1          00f864c493fa82a7                    rootvg          active

# lsvg
rootvg

# lsvg -l rootvg
rootvg:
LV NAME             TYPE       LPs     PPs     PVs  LV STATE      MOUNT POINT
hd5                 boot       1       2       2    closed/syncd  N/A
hd6                 paging     48      96      2    open/syncd    N/A
hd8                 jfs2log    1       2       2    open/syncd    N/A
hd4                 jfs2       4       8       2    open/syncd    /
hd2                 jfs2       10      20      2    open/syncd    /usr
hd9var              jfs2       4       8       2    open/syncd    /var
hd3                 jfs2       12      24      2    open/syncd    /tmp
hd1                 jfs2       2       4       4    open/syncd    /home
hd10opt             jfs2       6       12      2    open/syncd    /opt
hd11admin           jfs2       1       2       2    open/syncd    /admin
dumplv0             sysdump    8       8       2    open/syncd    N/A
lvu01               jfs2       100     200     2    open/syncd    /u01
livedump            jfs2       1       2       2    open/syncd    /var/adm/ras/livedump
lvtempdata          jfs2       846     1692    4    open/syncd    /tempdata
dumplv1             sysdump    4       4       1    open/syncd    N/A
```

查看VxVM情况

```
# vxdisk -e list
DEVICE       TYPE           DISK        GROUP        STATUS               OS_NATIVE_NAME   ATTR
disk_0       auto:LVM       -            -           LVM                  hdisk0           -
disk_2       auto:LVM       -            -           LVM                  hdisk32          -
disk_3       auto:LVM       -            -           LVM                  hdisk31          -
disk_4       auto:LVM       -            -           LVM                  hdisk1           -
ds3400-0_0   auto:cdsdisk   -            -           online               hdisk30          -
ds3400-0_1   auto:cdsdisk   -            -           online               hdisk28          -
ds3400-0_2   auto:cdsdisk   -            -           online               hdisk26          -
ds3400-0_3   auto:cdsdisk   -            -           online               hdisk27          -
ds3400-0_4   auto:cdsdisk   -            -           online               hdisk29          -
ds5020-0_0   auto:cdsdisk   -            -           online shared        hdisk3           -
ds5020-0_1   auto:cdsdisk   oradatadg01  oradatadg   online failing       hdisk5           -
ds5020-0_2   auto:cdsdisk   oradatadg02  oradatadg   online               hdisk7           -
ds5020-0_3   auto:cdsdisk   oradatadg03  oradatadg   online               hdisk9           -
ds5020-0_4   auto:cdsdisk   oradatadg04  oradatadg   online               hdisk11          -
ds5020-0_5   auto:cdsdisk   oradatadg05  oradatadg   online               hdisk13          -
ds5020-0_6   auto:cdsdisk   -            -           online shared        hdisk15          -
ds5020-0_7   auto:cdsdisk   -            -           online               hdisk17          -
ds5020-0_8   auto:cdsdisk   -            -           online               hdisk19          -
ds5020-0_9   auto:cdsdisk   oradatadg06  oradatadg   online               hdisk21          -
ds5020-0_10  auto:cdsdisk   oradatadg07  oradatadg   online               hdisk23          -
ds5020-0_11  auto:cdsdisk   -            -           online shared        hdisk24          -
ds5020-0_12  auto:cdsdisk   -            -           online shared        hdisk25          -
ds5020-0_13  auto:cdsdisk   -            -           online               hdisk2           -
ds5020-0_14  auto:cdsdisk   -            -           online               hdisk4           -
ds5020-0_15  auto:cdsdisk   oradatadg08  oradatadg   online               hdisk6           -
ds5020-0_16  auto:cdsdisk   archdg01     archdg      online               hdisk8           -
ds5020-0_17  auto:cdsdisk   archdg02     archdg      online               hdisk10          -
ds5020-0_18  auto:cdsdisk   archdg03     archdg      online               hdisk12          -
ds5020-0_19  auto:cdsdisk   oradatatempdg01  oradatatempdg online failing       hdisk14          -
ds5020-0_20  auto:cdsdisk   -            -           online               hdisk16          -
ds5020-0_21  auto:cdsdisk   -            -           online               hdisk18          -
ds5020-0_22  auto:cdsdisk   archdg04     archdg      online               hdisk20          -
ds5020-0_23  auto:cdsdisk   archdg05     archdg      online               hdisk22          -
ds5020-0_24  auto:ASM       -            -           ASM                  hdisk33          -
```


kfod - Kernel Files OSM Disk

```
$ kfod disk=all
--------------------------------------------------------------------------------
 Disk          Size Path                                     User     Group
================================================================================
   1:     409600 Mb /dev/rhdisk33                            grid     asmadmin
   2:     433152 Mb /dev/rlvtempdata                         grid     asmadmin
   3:     501760 Mb /dev/vx/rdsk/archdg/archvol              grid     asmadmin
   4:     409600 Mb /dev/vx/rdsk/oradatadg/oradatavol        grid     asmadmin
   5:     194560 Mb /dev/vx/rdsk/oradatadg/oradatavol2       grid     asmadmin
   6:     194560 Mb /dev/vx/rdsk/oradatadg/srlvol            grid     asmadmin
   7:      92160 Mb /dev/vx/rdsk/oradatatempdg/oradatatempvol grid     asmadmin
--------------------------------------------------------------------------------
ORACLE_SID ORACLE_HOME
================================================================================
      +ASM /u01/app/11.2.0/grid
```



```
SQL> select path,header_status,state,os_mb from v$asm_disk;

PATH                                               HEADER_STATU STATE         OS_MB
-------------------------------------------------- ------------ -------- ----------
/dev/vx/rdsk/oradatadg/oradatavol2                 CANDIDATE    NORMAL       194560
/dev/vx/rdsk/oradatadg/srlvol                      CANDIDATE    NORMAL       194560
/dev/vx/rdsk/archdg/archvol                        MEMBER       NORMAL       501760
/dev/vx/rdsk/oradatadg/oradatavol                  MEMBER       NORMAL       409600
/dev/vx/rdsk/oradatatempdg/oradatatempvol          MEMBER       NORMAL        92160
/dev/rhdisk33                                      MEMBER       NORMAL       409600
/dev/rlvtempdata                                   MEMBER       NORMAL       433152

7 rows selected.
```

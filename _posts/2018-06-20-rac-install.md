---
title: "rac silent install"
layout: post
category: linux
---


## [RAC](https://www.linuxidc.com/Linux/2015-10/124127.htm)


### install software

```
yum -y update
yum -y groupinstall "Development Tools"
yum -y install man mlocate vim screen smartmontools sysstat gcc gcc-c++ make binutils \
    compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel glibc ntpdate glibc-common \
    glibc-devel libaio libaio-devel libgcc libstdc++ libstdc++-devel unixODBC mlocate \
    unixODBC-devel xorg-x11-xauth tcpdump strace lsof bc nmap kmod-oracleasm oracleasm-support\
    sg3_utils

rpm -ivh /stage/grid/rpm/cvuqdisk-1.0.9-1.rpm
rpm -ivh /stage/software/*rpm
```


```
yum -y install screen
screen sh -c 'yum -y update; yum -y groupinstall "Development Tools"; yum -y install man mlocate vim screen smartmontools sysstat; yum -y install  gcc gcc-c++ make binutils compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel glibc glibc-common glibc-devel libaio libaio-devel libgcc libstdc++ libstdc++-devel unixODBC unixODBC-devel; yum -y install xorg-x11-xauth kmod-oracleasm oracleasm-support tcpdump strace lsof bc nmap sg3_utils'
```

---

+ hosts

```
cat >> /etc/hosts << EOF
10.255.255.21   prim1
10.255.255.22   prim2
10.255.255.23   prim-vip
10.255.255.24   prim2-vip
10.255.255.25   prim-scan
192.168.0.1     prim1-priv
192.168.0.2     prim2-priv

10.255.255.121  stb1
10.255.255.122  stb2
10.255.255.123  stb1-vip
10.255.255.124  stb2-vip
10.255.255.125  stb-scan
192.168.255.21  stb1-priv
192.168.255.22  stb2-priv
EOF

```

+ change hostname

```
sysctl kernel.hostname=primary1
```

---

+ 防火墙和selinux

```
chkconfig iptables off
service iptables stop
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
```

+ sysctl

```
cat >> /etc/sysctl.conf << EOF
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
fs.aio-max-nr = 1048576
fs.file-max = 6815744
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 1048576
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
EOF

sysctl -p
```

+ sudoer

```
sed -i 's/^# %wheel/%wheel/' /etc/sudoers
```

+ limit

```
cat >> /etc/security/limits.conf  << EOF
oracle soft nproc 2047
oracle hard nproc 16384
oracle soft nofile 1024
oracle hard nofile 65536
grid soft nproc 2047
grid hard nproc 16384
grid soft nofile 1024
grid hard nofile 65536
EOF
```

+ pam

```
cat >> /etc/pam.d/login << EOF
session required /lib64/security/pam_limits.so
EOF
```

+ change lib name

```
ln -s /lib64/libcap.so.2.16 /lib64/libcap.so.1
```

+ sshd

```
sed -i 's/^#UseDNS/UseDNS/' /etc/ssh/sshd_config
/etc/init.d/sshd restart
```



---

### ssh-copy-id 

略

---


+ add user 

```
groupadd -g 1000 oinstall
groupadd -g 1001 asmadmin
groupadd -g 1002 dba
groupadd -g 1003 asmdba 
useradd -u 1000 -d /home/oracle -g oinstall -G dba,asmdba,wheel oracle 
useradd -u 1001 -d /home/grid -g oinstall -G asmadmin,asmdba,wheel,dba grid
echo -e "oracle\noracle" | passwd oracle
echo -e "oracle\noracle" | passwd grid
```

+ mkdir

```
mkdir /stage
mkdir -p /u01/app/11.2.0/grid
mkdir -p /u01/app/oraInventory
mkdir -p /u01/app/grid
chown -R grid.oinstall /u01
chown -R grid.oinstall /stage
```

```
mkdir -p /u01/app/oracle/product/11.2.0/dbhome_1 
chown -R oracle.oinstall  /u01/app/oracle
chmod -R 775 /u01
```


~~配置iscsi连接openfiler存储,此处要根据实际情况设置,这里是一个40G的盘,分成两个20G的区~~
```
yum -y install iscsi-initiator-utils
iscsiadm -m discovery -t sendtargets -p 192.108.26.100:3260
service iscsi restart
```


~~raw the device~~

~~[使用udev的原因,但是12开始淘汰](https://blog.csdn.net/u010098331/article/details/51623371)~~

```
cat >> /etc/udev/rules.d/60-raw.rules << EOF
ACTION=="add", KERNEL=="/dev/sdb1",RUN+="/bin/raw /dev/raw/raw1 %N"
ACTION=="add", ENV{MAJOR}=="8",ENV{MINOR}=="17",RUN+="/bin/raw /dev/raw/raw1 %M %m"
ACTION=="add", KERNEL=="/dev/sdb2",RUN+="/bin/raw /dev/raw/raw2 %N"
ACTION=="add", ENV{MAJOR}=="8",ENV{MINOR}=="18",RUN+="/bin/raw /dev/raw/raw2 %M %m"
KERNEL=="raw[1-2]", OWNER="grid", GROUP="asmadmin", MODE="660"
EOF

start_udev
ls /dev/raw/ -l
```

---

### [create asmdisk](https://www.oracle.com/linux/downloads/linux-asmlib-rhel6-downloads.html)

```
# 启动
oracleasm init

# 配置
/etc/init.d/oracleasm configure
ORACLEASM_ENABLED=true
ORACLEASM_UID=grid
ORACLEASM_GID=asmadmin
ORACLEASM_SCANBOOT=true
ORACLEASM_SCANORDER=""
ORACLEASM_SCANEXCLUDE=""
ORACLEASM_USE_LOGICAL_BLOCK_SIZE="false"

# 用asmtool


sudo /usr/sbin/asmtool -C -l /dev/oracleasm -n DATA -s /dev/mapper/storage-data -a force=yes
sudo /usr/sbin/asmtool -C -l /dev/oracleasm -n FRA  -s /dev/mapper/storage-fra  -a force=yes
sudo /usr/sbin/asmtool -C -l /dev/oracleasm -n OCR1 -s /dev/mapper/storage-ocr1 -a force=yes
sudo /usr/sbin/asmtool -C -l /dev/oracleasm -n OCR2 -s /dev/mapper/storage-ocr2 -a force=yes
sudo /usr/sbin/asmtool -C -l /dev/oracleasm -n OCR3 -s /dev/mapper/storage-ocr3 -a force=yes

oracleasm scandisks
oracleasm listdisks

grid@pri1 ~ $  ls -lht /dev/oracleasm/disks/
total 0
brw-rw---- 1 grid asmadmin 8, 144 Dec 28 11:16 OCR1
brw-rw---- 1 grid asmadmin 8, 112 Dec 28 11:16 OCR3
brw-rw---- 1 grid asmadmin 8,  80 Dec 28 11:16 FRA
brw-rw---- 1 grid asmadmin 8,  48 Dec 28 11:16 OCR2
brw-rw---- 1 grid asmadmin 8,  16 Dec 28 11:16 DATA

```



--- 

## grid install

grid user .bash_profile

```
PS1='\[\e[0;33m\]\u@\h\[\e[m\] \[\e[1;36m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[1;37m\]'
LS_COLORS=$LS_COLORS:'di=1;36:ln=36'
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend
HISTSIZE=30000
HISTFILESIZE=300000
HISTTIMEFORMAT="%F %T "
LANG="en_US.utf8"
LC_ALL="en_US.utf8"
export EDITOR="vim"
export PATH
export TMP=/tmp
export TMPDIR=$TMP
export ORACLE_BASE=/u01/app/grid
export ORACLE_HOME=/u01/app/11.2.0/grid
export GRID_HOME=/u01/app/11.2.0/grid
export CRS_HOME=$GRID_HOME
export ORACLE_SID=+ASM1
umask 022
PATH=$ORACLE_HOME/bin:$PATH
alias sqlplus='rlwrap -A sqlplus'
alias rman='rlwrap -A rman'
alias dgmgrl='rlwrap -A dgmgrl'
alias asmcmd='rlwrap -A asmcmd'
```

#### /stage/grid/response/grid_install.rsp

```
oracle.install.responseFileVersion=/oracle/install/rspfmt_crsinstall_response_schema_v11_2_0
ORACLE_HOSTNAME=pri1
INVENTORY_LOCATION=/u01/app/oraInventory
SELECTED_LANGUAGES=en
oracle.install.option=CRS_CONFIG
ORACLE_BASE=/u01/app/grid
ORACLE_HOME=/u01/app/11.2.0/grid
oracle.install.asm.OSDBA=asmdba
oracle.install.asm.OSOPER=oinstall
oracle.install.asm.OSASM=asmadmin
oracle.install.crs.config.gpnp.scanName=pri-scan
oracle.install.crs.config.gpnp.scanPort=1521
oracle.install.crs.config.clusterName=pri-cluster
oracle.install.crs.config.gpnp.configureGNS=false
oracle.install.crs.config.gpnp.gnsSubDomain=
oracle.install.crs.config.gpnp.gnsVIPAddress=
oracle.install.crs.config.autoConfigureClusterNodeVIP=false
oracle.install.crs.config.clusterNodes=pri1:pri1-vip,pri2:pri2-vip
oracle.install.crs.config.networkInterfaceList=eth0:10.0.2.0:3,eth1:10.255.255.0:1,eth2:192.168.0.0:2,eth3:192.168.1.0:3
oracle.install.crs.config.storageOption=ASM_STORAGE
oracle.install.crs.config.sharedFileSystemStorage.diskDriveMapping=
oracle.install.crs.config.sharedFileSystemStorage.votingDiskLocations=
oracle.install.crs.config.sharedFileSystemStorage.votingDiskRedundancy=NORMAL
oracle.install.crs.config.sharedFileSystemStorage.ocrLocations=
oracle.install.crs.config.sharedFileSystemStorage.ocrRedundancy=NORMAL
oracle.install.crs.config.useIPMI=false
oracle.install.crs.config.ipmi.bmcUsername=
oracle.install.crs.config.ipmi.bmcPassword=oracle
oracle.install.asm.SYSASMPassword=oracle
oracle.install.asm.diskGroup.name=OCR
oracle.install.asm.diskGroup.redundancy=NORMAL
oracle.install.asm.diskGroup.AUSize=1
oracle.install.asm.diskGroup.disks=ORCL:OCR1,ORCL:OCR2,ORCL:OCR3
oracle.install.asm.diskGroup.diskDiscoveryString=ORCL:*
oracle.install.asm.monitorPassword=oracle
oracle.install.crs.upgrade.clusterNodes=
oracle.install.asm.upgradeASM=false
oracle.installer.autoupdates.option=SKIP_UPDATES
oracle.installer.autoupdates.downloadUpdatesLoc=
AUTOUPDATES_MYORACLESUPPORT_USERNAME=
AUTOUPDATES_MYORACLESUPPORT_PASSWORD=
PROXY_HOST=
PROXY_PORT=0
PROXY_USER=
PROXY_PWD=
PROXY_REALM=
```

---

检验环境是否OK

```
/stage/grid/runcluvfy.sh stage -pre crsinst -n pri1,pri2
```

安装, 只在stb1

```
-- asm delete files

/stage/grid/runInstaller -responseFile /stage/grid/response/grid_install.rsp -silent -ignorePrereq -showProgress
```


+ log location

```
/u01/app/oraInventory/logs/installActions<TIMESTAMP>.log
```

注册/安装, 这里注意要先完成node1，再去完成node2，否则sid会乱，而且脑裂争抢OCR

```
As a root user, execute the following script(s):
        1. /u01/app/oraInventory/orainstRoot.sh
        2. /u01/app/11.2.0/grid/root.sh

As install user, execute the following script to complete the configuration.
        1. /u01/app/11.2.0/grid/cfgtoollogs/configToolAllCommands RESPONSE_FILE=response_file_location

```


grid 静默安装后，执行完root安装后，用stb1的grid用户再执行一次cfgrsp的密码相关配置
[Running Postinstallation Configuration Using a Response File](https://docs.oracle.com/cd/E11882_01/install.112/e41961/app_nonint.htm#CWLIN379)


```
cat >> /stage/grid/response/pwdrsp.properties << EOF 
grid.crs|S_ASMPASSWORD=oracle
grid.crs|S_OMSPASSWORD=oracle
grid.crs|S_BMCPASSWORD=oracle
grid.crs|S_ASMMONITORPASSWORD=oracle
EOF
```

```
/u01/app/11.2.0/grid/cfgtoollogs/configToolAllCommands RESPONSE_FILE=/stage/grid/response/pwdrsp.properties
```




## rdbms database install

### oracle .bash_profile

```
PATH=$PATH:$HOME/bin
PS1='\[\e[0;33m\]\u@\h\[\e[m\] \[\e[1;36m\]\w\[\e[m\] \[\e[1;32m\]$\[\e[m\] \[\e[1;37m\]'
LS_COLORS=$LS_COLORS:'di=1;36:ln=36'
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend
HISTSIZE=30000
HISTFILESIZE=300000
HISTTIMEFORMAT="%F %T "
LANG="en_US.utf8"
LC_ALL="en_US.utf8"
export EDITOR="vim"
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1
export ORACLE_SID=stbsid2
export PATH=$ORACLE_HOME/bin:$PATH
umask 022
alias sqlplus='rlwrap -A sqlplus'
alias dgmgrl='rlwrap -A dgmgrl'
alias rman='rlwrap -A rman'
```


---

### create disk group


```
CREATE DISKGROUP DATA EXTERNAL REDUNDANCY DISK 'ORCL:DATA';
CREATE DISKGROUP FRA  EXTERNAL REDUNDANCY DISK 'ORCL:FRA' ;
```

or

```
CREATE DISKGROUP DATA EXTERNAL REDUNDANCY DISK '/dev/raw/raw4';
CREATE DISKGROUP FRA  EXTERNAL REDUNDANCY DISK '/dev/raw/raw5';
```

### /stage/database/response/db_install.rsp

```
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v11_2_0
oracle.install.option=INSTALL_DB_AND_CONFIG
ORACLE_HOSTNAME=pri1
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=/u01/app/oraInventory
SELECTED_LANGUAGES=en
ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
ORACLE_BASE=/u01/app/oracle
oracle.install.db.InstallEdition=EE
oracle.install.db.EEOptionsSelection=false
oracle.install.db.optionalComponents=
oracle.install.db.DBA_GROUP=dba
oracle.install.db.OPER_GROUP=
oracle.install.db.CLUSTER_NODES=pri1,pri2
oracle.install.db.isRACOneInstall=false
oracle.install.db.racOneServiceName=
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
oracle.install.db.config.starterdb.globalDBName=oradata
oracle.install.db.config.starterdb.SID=pri
oracle.install.db.config.starterdb.characterSet=AL32UTF8
oracle.install.db.config.starterdb.memoryOption=true
oracle.install.db.config.starterdb.memoryLimit=256
oracle.install.db.config.starterdb.installExampleSchemas=false
oracle.install.db.config.starterdb.enableSecuritySettings=true
oracle.install.db.config.starterdb.password.ALL=oracle
oracle.install.db.config.starterdb.password.SYS=
oracle.install.db.config.starterdb.password.SYSTEM=
oracle.install.db.config.starterdb.password.SYSMAN=
oracle.install.db.config.starterdb.password.DBSNMP=
oracle.install.db.config.starterdb.control=DB_CONTROL
oracle.install.db.config.starterdb.gridcontrol.gridControlServiceURL=
oracle.install.db.config.starterdb.automatedBackup.enable=false
oracle.install.db.config.starterdb.automatedBackup.osuid=
oracle.install.db.config.starterdb.automatedBackup.ospwd=
oracle.install.db.config.starterdb.storageType=ASM_STORAGE
oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=
oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=
oracle.install.db.config.asm.diskGroup=DATA
oracle.install.db.config.asm.ASMSNMPPassword=oracle
MYORACLESUPPORT_USERNAME=
MYORACLESUPPORT_PASSWORD=
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false
DECLINE_SECURITY_UPDATES=true
PROXY_HOST=
PROXY_PORT=
PROXY_USER=
PROXY_PWD=
PROXY_REALM=
COLLECTOR_SUPPORTHUB_URL=
oracle.installer.autoupdates.option=SKIP_UPDATES
oracle.installer.autoupdates.downloadUpdatesLoc=
AUTOUPDATES_MYORACLESUPPORT_USERNAME=
AUTOUPDATES_MYORACLESUPPORT_PASSWORD=
```

RAC software only

```
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v11_2_0
oracle.install.option=INSTALL_DB_SWONLY
ORACLE_HOSTNAME=stb1
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=/u01/app/oraInventory
SELECTED_LANGUAGES=en
ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
ORACLE_BASE=/u01/app/oracle
oracle.install.db.InstallEdition=EE
oracle.install.db.EEOptionsSelection=false
oracle.install.db.optionalComponents=
oracle.install.db.DBA_GROUP=dba
oracle.install.db.OPER_GROUP=
oracle.install.db.CLUSTER_NODES=stb1,stb2
oracle.install.db.isRACOneInstall=false
oracle.install.db.racOneServiceName=
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
oracle.install.db.config.starterdb.globalDBName=
oracle.install.db.config.starterdb.SID=
oracle.install.db.config.starterdb.characterSet=
oracle.install.db.config.starterdb.memoryOption=false
oracle.install.db.config.starterdb.memoryLimit=
oracle.install.db.config.starterdb.installExampleSchemas=false
oracle.install.db.config.starterdb.enableSecuritySettings=true
oracle.install.db.config.starterdb.password.ALL=
oracle.install.db.config.starterdb.password.SYS=
oracle.install.db.config.starterdb.password.SYSTEM=
oracle.install.db.config.starterdb.password.SYSMAN=
oracle.install.db.config.starterdb.password.DBSNMP=
oracle.install.db.config.starterdb.control=DB_CONTROL
oracle.install.db.config.starterdb.gridcontrol.gridControlServiceURL=
oracle.install.db.config.starterdb.automatedBackup.enable=false
oracle.install.db.config.starterdb.automatedBackup.osuid=
oracle.install.db.config.starterdb.automatedBackup.ospwd=
oracle.install.db.config.starterdb.storageType=
oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=
oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=
oracle.install.db.config.asm.diskGroup=
oracle.install.db.config.asm.ASMSNMPPassword=
MYORACLESUPPORT_USERNAME=
MYORACLESUPPORT_PASSWORD=
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false
DECLINE_SECURITY_UPDATES=true
PROXY_HOST=
PROXY_PORT=
PROXY_USER=
PROXY_PWD=
PROXY_REALM=
COLLECTOR_SUPPORTHUB_URL=
oracle.installer.autoupdates.option=SKIP_UPDATES
oracle.installer.autoupdates.downloadUpdatesLoc=
AUTOUPDATES_MYORACLESUPPORT_USERNAME=
AUTOUPDATES_MYORACLESUPPORT_PASSWORD=
```

check

```
/stage/grid/runcluvfy.sh stage -pre dbinst -n stb1,stb2 -verbose
```

install rdbms,  和grid的runInstaller一样，只在stb1

```
/stage/database/runInstaller -ignorePrereq -silent -force -responseFile /stage/database/response/db_install.rsp -showProgress
```

+ log location

```
/u01/app/oraInventory/logs/installActions<TIMESTAMP>.log
```


---

### 让oracle有asm使用权限


```
# 
oracle@stb1:~$ ls -l $ORACLE_HOME/bin/oracle
-rwsr-s--x. 1 oracle oinstall 239626641 Apr 14 11:45 oracle

grid@stb1:~$ setasmgidwrap o=/u01/app/oracle/product/12.2.0/dbhome_1/bin/oracle

grid@stb1:~$ ls -l oracle
-rwsr-s--x. 1 oracle asmadmin 239626642 Apr 14 11:45 oracle

```

---
-- 删除旧服务
$ srvctl remove database -d orcl
-- 添加服务 用oracle用户
oracle@host ~ $ srvctl add database -d ee -o /u01/app/oracle/product/11.2.0/dbhome_1
srvctl add database -d $ORACLE_SID -o $ORACLE_HOME

-- standalone db
sudo $GRID_HOME/bin/crsctl delete resource  ora.oradb.db
-- rac
srvctl add database -d db_unique_name -r PRIMARY -n db_name -o $ORACLE_HOME
-- srvctl add database -d db_unique_name -r PHYSICAL_STANDBY -n db_name -o $ORACLE_HOME
srvctl add instance -d db_unique_name -i $ORACLE_SID -n $HOSTNAME
srvctl add instance -d db_unique_name -i $ORACLE_SID -n $HOSTNAME

```

---

### dbca 

上面的runInstall会自动完成DBCA如下

```
/u01/app/oracle/product/11.2.0/dbhome_1/bin/dbca -silent -createDatabase -templateName General_Purpose.dbc -sid stbsid -gdbName oradb -emConfiguration LOCAL -storageType ASM -diskGroupName DATA -datafileJarLocation /u01/app/oracle/product/11.2.0/dbhome_1/assistants/dbca/templates -responseFile /stage/database/response/db_install.rsp -nodeinfo stb1,stb2 -characterset AL32UTF8 -obfuscatedPasswords false -oratabLocation /u01/app/oracle/product/11.2.0/dbhome_1/install/oratab -automaticMemoryManagement true -totalMemory 1024 -maskPasswords false -oui_internal
```


---

## rac as physical standby

stbsid1 在rman duplicate后，开启stbsid2后出现 **ORA-00304: requested INSTANCE_NUMBER is busy** 异常


先调整pfile， 注意 **sid** 和 **thread**

然后在调整 参数，例如已经启动stbsid1，就在stbsid1中设置：


```
alter system set INSTANCE_NUMBER=1 scope=spfile sid='stbsid1';
alter system set INSTANCE_NUMBER=2 scope=spfile sid='stbsid2';
```

---

### **db_recovery_file_dest** 需在共享存储。

### ORA-00245 & RMAN-03009


需要讲spfile和controlfile snapshot放置在共享存储

```
RMAN> CONFIGURE SNAPSHOT CONTROLFILE NAME TO '+<DiskGroup>/snapcf_<DBNAME>.f';
```

---

### instance change thread number

首先需要确认的是spfile是一致的，controlfile是一致的。调整**$ORACLE_SID**即可


---

## database and grid uninstall

输入删除命令，然后会有cli向导进行删除

```
$ORACLE_HOME/deinstall/deinstall
```

### grid卸载 [Clean Up a Failed Grid Infrastruture Installation](https://oracle-base.com/articles/rac/clean-up-a-failed-grid-infrastructure-installation)

#### grid

+ On all cluster nodes except the last, run the following command as the "root" user.

```
# perl $GRID_HOME/crs/install/rootcrs.pl -verbose -deconfig -force
```

+ On the last cluster node, run the following command as the "root" user.

```
# perl $GRID_HOME/crs/install/rootcrs.pl -verbose -deconfig -force -lastnode
```

This final command will blank the OCR configuration and voting disk.

### asm disks 卸载/重建


```
# dd if=/dev/zero of=/dev/sdb1 bs=1024 count=100

# /etc/init.d/oracleasm deletedisk DATA /dev/sdb1
# /etc/init.d/oracleasm createdisk DATA /dev/sdb1
```

---

### [asmtools: kfod, kfed, amdu](https://www.hhutzler.de/blog/asm-tools-used-by-support-kfod-kfed-amdu-doc-id-1485597-1/)

#### kfod - Kernel Files OSM Disk

```
kfod disk=all
kfod status=true g=OCR
```

#### kfed - Kernel Files metadata EDitor

```
kfed read ORCL:ORC1
kfed read ORCL:ORC1 | grep -P "kfdhdb.hdrsts|kfdhdb.dskname|kfdhdb.grpname|kfdhdb.fgname|kfdhdb.secsize|blksize|driver.provstr|kfdhdb.ausize"
```

#### amdu - ASM Metadata Dump Utility

. Dumps metadata for ASM disks
. Extract the content of ASM files even DG isn't mounted


```
asmcmd lsdg | grep -i ocr
amdu -diskstring 'ORCL:*' -dump 'OCR'
```


---


## [add nodes](https://docs.oracle.com/cd/E11882_01/rac.112/e41960/adddelunix.htm#RACAD7903)

```
export IGNORE_PREADDNODE_CHECKS=Y
/u01/app/11.2.0/grid/oui/bin/addNode.sh "CLUSTER_NEW_NODES={primary3}" "CLUSTER_NEW_VIRTUAL_HOSTNAMES={primary3-vip}"
```

```
As a root user, execute the following script(s):
    1. /u01/app/oraInventory/orainstRoot.sh
    2. /u01/app/11.2.0/grid/root.sh
```

```
crsctl check cluster -all
```

---

## [delete nodes](https://docs.oracle.com/cd/E11882_01/rac.112/e41960/adddelunix.htm#RACAD7903)



---

### 测试系统关闭一下资源


删除 tfa

sudo rm /etc/init/oracle-tfa.conf

. [ologgerd](https://www.rocworks.at/wordpress/?p=271)

```
crsctl stop resource ora.crf -init
sudo `which crsctl` delete resource ora.crf -init

crsctl stop resource ora.oc4j
```



---

### sample install


```
unzip p13390677_112040_Linux-x86-64_6of7.zip
```

**demos_install.rsp**

```
oracle.install.responseFileVersion=/oracle/install/rspfmt_demosinstall_response_schema_v11_2_0
ORACLE_HOSTNAME=rac1
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=/u01/app/oraInventory/
SELECTED_LANGUAGES=en,zh_CN
ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
ORACLE_BASE=/u01/app/oracle
oracle.installer.autoupdates.option=
oracle.installer.autoupdates.option=SKIP_UPDATES
oracle.installer.autoupdates.downloadUpdatesLoc=
AUTOUPDATES_MYORACLESUPPORT_USERNAME=
AUTOUPDATES_MYORACLESUPPORT_PASSWORD=
PROXY_HOST=
PROXY_PORT=
PROXY_USER=
PROXY_PWD=
PROXY_REALM=
```

. install

```
./runInstaller -silent -force -ignorePrereq -ignoreSysPrereqs -responseFile /stage/examples/response/demos_install.rsp
```

sql insert

```
SQL>@?/demo/schema/human_resources/hr_main.sql

specify password for HR as parameter 1:
Enter value for 1: hr

specify default tablespeace for HR as parameter 2:
Enter value for 2: USERS

specify temporary tablespace for HR as parameter 3:
Enter value for 3: TEMPTS1

specify password for SYS as parameter 4:
Enter value for 4: oracle

specify log path as parameter 5:
Enter value for 5: /u01/app/oracle/product/11.2.0/db_1/demo/schema/log/



SQL> @?/demo/schema/sales_history/sh_main.sql

specify password for SH as parameter 1:
Enter value for 1: sh

specify default tablespace for SH as parameter 2:
Enter value for 2: USERS

specify temporary tablespace for SH as parameter 3:
Enter value for 3: TEMP

specify password for SYS as parameter 4:
Enter value for 4: PASSWORD

specify directory path for the data files as parameter 5:
Enter value for 5: +DATA

writeable directory path for the log files as parameter 6:
Enter value for 6: /u01/app/oracle/product/11.2.0/dbhome_1/demo/schema/log

specify version as parameter 7:
Enter value for 7: v3

```

---

### [sample install manual](https://github.com/oracle/db-sample-schemas#README.txt)

```
cd $HOME/db-sample-schemas
git pull
cp -r $HOME/db-sample-schemas /tmp/
cd /tmp/db-sample-schemas
perl -p -i.bak -e 's#__SUB__CWD__#'$(pwd)'#g' *.sql */*.sql */*.dat 
docker cp /tmp/db-sample-schemas oracle:/tmp/
...

sqlplus system/oracle@localhost/EE.oracle.docker @/tmp/db-sample-schemas/mksample oracle oracle hr oe pm ix sh bi USERS TEMP /tmp/sample_install.log localhost/EE.oracle.docker

```



--- 

### [hotplug attribute on network cards](https://anuragkumarjoy.blogspot.com/2018/05/)

To find all network cards used by clusterware run following command.

```
$CRS_HOME/bin/oifcfg getif
```

---

### asmstring

cat $ORACLE_HOME/gpnp/profiles/peer/profile.xml

---

## create database


initstb1.ora

```
*.DB_NAME=ORADB
*.DB_UNIQUE_NAME=STBDB
*.DB_BLOCK_SIZE=8192
*.CONTROL_FILES='+DATA/stbdb/controlfile/controlfile.ctl'
*.UNDO_TABLESPACE=UNDOTBS1
*.UNDO_MANAGEMENT=AUTO
*.SGA_TARGET=296M
*.PGA_AGGREGATE_TARGET=90M
*.standby_file_management=auto
*.db_create_file_dest=+DATA
*.DB_RECOVERY_FILE_DEST=+FRA
*.DB_RECOVERY_FILE_DEST_SIZE=5G
*.cluster_database=false
*.cluster_database_instances=2
stb1.instance_name=stb1
stb1.instance_number=1
stb1.thread=1
stb1.undo_tablespace=UNDOTBS1
```


createdb.sql

```
CREATE DATABASE ORADB
MAXINSTANCES 32
MAXLOGHISTORY 1
MAXLOGFILES 192
MAXLOGMEMBERS 3
MAXDATAFILES 1024
DATAFILE '+DATA' SIZE 700M REUSE AUTOEXTEND ON NEXT 10240K MAXSIZE UNLIMITED
EXTENT MANAGEMENT LOCAL
SYSAUX DATAFILE '+DATA' SIZE 550M REUSE AUTOEXTEND ON NEXT 10240K MAXSIZE UNLIMITED
SMALLFILE DEFAULT TABLESPACE USERS DATAFILE '+DATA' SIZE 500M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
SMALLFILE DEFAULT TEMPORARY TABLESPACE TEMP TEMPFILE '+DATA' SIZE 20M REUSE AUTOEXTEND ON NEXT 640K MAXSIZE UNLIMITED
SMALLFILE UNDO TABLESPACE "UNDOTBS1" DATAFILE '+DATA' SIZE 200M REUSE AUTOEXTEND ON NEXT 5120K MAXSIZE UNLIMITED
CHARACTER SET AL32UTF8
NATIONAL CHARACTER SET UTF8
LOGFILE GROUP 1, GROUP 2 , GROUP 3 
USER SYS IDENTIFIED BY oracle USER SYSTEM IDENTIFIED BY oracle;
```

build views, synonyms, etc.

```
@?/rdbms/admin/catalog.sql
@?/rdbms/admin/catproc.sql
@?/rdbms/admin/catclust.sql
```


add thread to rac2

```
CREATE UNDO TABLESPACE UNDOTBS2 datafile '+DATA'; 
alter database add logfile thread 2 group 4 , group 5 , group 6 ;

alter database enable public thread 2;
alter system set cluster_database=true sid='*' scope=spfile;
```


config pfile

```
stb2.instance_name=stb2
stb2.instance_number=2
stb2.thread=2
stb2.undo_tablespace=UNDOTBS2
```


 register in crs

```
srvctl add database -d stbdb -r PRIMARY -n ORADB -o $ORACLE_HOME
srvctl add instance -d stbdb -i stb1 -n stb1
srvctl add instance -d stbdb -i stb2 -n stb2
```


## drop database

alter system set cluster_database=FALSE scope=spfile;
startup mount exclusive restrict force;
Drop Database;

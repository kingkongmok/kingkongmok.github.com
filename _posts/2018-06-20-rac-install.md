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
yum -y install vim screen smartmontools sysstat gcc gcc-c++ make binutils \
    compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel glibc ntpdate glibc-common \
    glibc-devel libaio libaio-devel libgcc libstdc++ libstdc++-devel unixODBC mlocate \
    unixODBC-devel xorg-x11-xauth tcpdump strace lsof bc nmap kmod-oracleasm oracleasm-support

rpm -ivh /stage/grid/rpm/cvuqdisk-1.0.9-1.rpm
rpm -ivh /stage/software/*rpm
```


```
yum -y install screen
screen sh -c 'yum -y update; yum -y groupinstall "Development Tools"; yum -y install vim screen smartmontools sysstat; yum -y install  gcc gcc-c++ make binutils compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel glibc glibc-common glibc-devel libaio libaio-devel libgcc libstdc++ libstdc++-devel unixODBC unixODBC-devel; yum -y install xorg-x11-xauth kmod-oracleasm oracleasm-support tcpdump strace lsof bc nmap'
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

+ ulimit

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
useradd -u 1001 -d /home/grid -g oinstall -G asmadmin,asmdba,wheel grid
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
/usr/sbin/asmtool -C -l /dev/oracleasm -n OCR1 -s /dev/sdb -a force=yes
/usr/sbin/asmtool -C -l /dev/oracleasm -n OCR2 -s /dev/sdc -a force=yes
/usr/sbin/asmtool -C -l /dev/oracleasm -n OCR3 -s /dev/sdd -a force=yes
/usr/sbin/asmtool -C -l /dev/oracleasm -n DATA -s /dev/sde -a force=yes
/usr/sbin/asmtool -C -l /dev/oracleasm -n FRA -s /dev/sdf -a force=yes
oracleasm scandisks
oracleasm listdisks
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
ORACLE_HOSTNAME=primary1
INVENTORY_LOCATION=/u01/app/oraInventory
SELECTED_LANGUAGES=en
oracle.install.option=CRS_CONFIG
ORACLE_BASE=/u01/app/grid
ORACLE_HOME=/u01/app/11.2.0/grid
oracle.install.asm.OSDBA=asmdba
oracle.install.asm.OSOPER=oinstall
oracle.install.asm.OSASM=asmadmin
oracle.install.crs.config.gpnp.scanName=primary-scan
oracle.install.crs.config.gpnp.scanPort=1521
oracle.install.crs.config.clusterName=primary-cluster
oracle.install.crs.config.gpnp.configureGNS=false
oracle.install.crs.config.gpnp.gnsSubDomain=
oracle.install.crs.config.gpnp.gnsVIPAddress=
oracle.install.crs.config.autoConfigureClusterNodeVIP=false
oracle.install.crs.config.clusterNodes=primary1:primary1-vip,primary2:primary2-vip
oracle.install.crs.config.networkInterfaceList=eth0:10.0.2.0:3,eth1:10.255.255.0:1,eth2:192.168.1.0:2,eth3:172.26.31.0:3
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
oracle.install.asm.diskGroup.diskDiscoveryString=
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
/stage/grid/runcluvfy.sh stage -pre crsinst -n stb1,stb2 -verbose
```

安装, 只在stb1

```
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




---

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
ORACLE_HOSTNAME=primary1
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
oracle.install.db.CLUSTER_NODES=primary1,primary2
oracle.install.db.isRACOneInstall=false
oracle.install.db.racOneServiceName=
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
oracle.install.db.config.starterdb.globalDBName=oradata
oracle.install.db.config.starterdb.SID=primary
oracle.install.db.config.starterdb.characterSet=AL32UTF8
oracle.install.db.config.starterdb.memoryOption=true
oracle.install.db.config.starterdb.memoryLimit=802
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


## add nodes

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

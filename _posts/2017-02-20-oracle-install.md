---
title: "oracle install"
layout: post
category: linux
---


+ update 


```
yum -y groupinstall "Development Tools"
```

+ software

```
yum -y install vim screen
yum -y install smartmontools sysstat
rpm -ivh /stage/grid/rpm/cvuqdisk-1.0.9-1.rpm
```


```
yum -y install  gcc gcc-c++ make binutils compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel glibc glibc-common glibc-devel libaio libaio-devel libgcc libstdc++ libstdc++-devel unixODBC unixODBC-devel
```


+ X11 forward

```
yum -y install xorg-x11-server-Xorg xorg-x11-xauth xorg-x11-apps

```

at xshell:

+ SSH: use Xagent, launch Xagent automatic
+ Tunnerling: Forward X11 

---

### sysctl.conf

```
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmall = 2097152
kernel.shmmax = 4294967295
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576

```

### /etc/security/limits.conf

```
oracle   soft   nproc    131072
oracle   hard   nproc    131072
oracle   soft   nofile   131072
oracle   hard   nofile   131072
oracle   soft   core     unlimited
oracle   hard   core     unlimited
oracle   soft   memlock  50000000
oracle   hard   memlock  50000000
```

### /etc/profile

```
ulimit -p 16384
ulimit -n 65536
```

### /etc/sudoers

###  /etc/pam.d/login

```
session required /lib64/security/pam_limits.so
```


## cmd


```

groupadd -g 500 oinstall
groupadd -g 501 dba
groupadd -g 502 oper
groupadd -g 503 asmdba
groupadd -g 504 asmoper
groupadd -g 505 asmadmin

useradd -u 500 -g oinstall -G dba,oper,asmdba,asmoper,asmadmin,wheel oracle


mkdir -p /u01/app/oraInventory
mkdir -p /u01/app/oracle/oradata
mkdir -p /u01/app/oracle/fast_recovery_area
mkdir -p /stage
chown -R oracle:oinstall /u01/app/
chown -R oracle:oinstall /stage/
chmod -R 775 /u01/app/
chmod -R 775 /stage/

```

### .bashrc

```
PS1='\[\e[0;33m\]\u@\h\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[1;37m\]'
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend
HISTSIZE=30000
HISTFILESIZE=300000
HISTTIMEFORMAT="%F %T "

LANG="en_US.utf8"
LC_ALL="en_US.utf8"
export EDITOR="vim"

# User specific aliases and functions
TMOUT=18000
```


## .bash_profile

```
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
export ORACLE_SID=orcl
export PATH=$ORACLE_HOME/bin:$PATH

```

## Error with responseFile config

### db_install.rsp 文件内容：

```
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v11_2_0
oracle.install.option=INSTALL_DB_SWONLY
ORACLE_HOSTNAME=localhost
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=/u01/app/oraInventory
SELECTED_LANGUAGES=en
ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
ORACLE_BASE=/u01/app/oracle
oracle.install.db.InstallEdition=EE
oracle.install.db.EEOptionsSelection=false
oracle.install.db.optionalComponents=
oracle.install.db.DBA_GROUP=oper
oracle.install.db.OPER_GROUP=oper
oracle.install.db.CLUSTER_NODES=
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
AUTOUPDATES_MYORACLESUPPORT_USERNAME=oracle
AUTOUPDATES_MYORACLESUPPORT_PASSWORD=

```


```
./database/runInstaller -silent -responseFile /home/oracle/db_install.rsp
```

---

## dbca

```
dbca -silent -createDatabase -templateName General_Purpose.dbc -gdbname orcl -sid orcl -responseFile NO_VALUE -characterSet AL32UTF8 -memoryPercentage 50 -emConfiguration LOCAL
```

然后输入 **SYS**, **SYSTEM**, **SYSMEM** 的密码

---

## netca

```
netca /silent /responsefile /stage/database/response/netca.rsp
```


---


## [RAC](https://www.linuxidc.com/Linux/2015-10/124127.htm)


### add raw

+ [root@rac1 stage]# cat /etc/udev/rules.d/60-raw.rules 

```
ACTION=="add", KERNEL=="/dev/sdb1",RUN+="/bin/raw /dev/raw/raw1 %N"
ACTION=="add", ENV{MAJOR}=="8",ENV{MINOR}=="17",RUN+="/bin/raw /dev/raw/raw1 %M %m"
ACTION=="add", KERNEL=="/dev/sdb2",RUN+="/bin/raw /dev/raw/raw2 %N"
ACTION=="add", ENV{MAJOR}=="8",ENV{MINOR}=="18",RUN+="/bin/raw /dev/raw/raw2 %M %m"
KERNEL=="raw[1-2]", OWNER="grid", GROUP="asmadmin", MODE="660"
```


+ hosts

```
10.255.255.21   rac1
10.255.255.22   rac2
10.255.255.23   rac1-vip
10.255.255.24   rac2-vip
10.255.255.25   rac-scan
192.168.0.1 rac1-priv
192.168.0.2 rac2-priv
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

---

### ssh-copy-id 

---


+ add user 

```
groupadd -g 1000 oinstall
groupadd -g 1001 asmadmin
groupadd -g 1002 dba
groupadd -g 1003 asmdba 
useradd -u 1000 -d /home/oracle -g oinstall -G dba,asmdba,wheel oracle 
useradd -u 1001 -d /home/grid -g oinstall -G asmadmin,asmdba,wheel grid
passwd oracle
passwd grid
```

+ mkdir

```
mkdir -p /u01/app/11.2.0/grid
mkdir -p /u01/app/oraInventory
mkdir -p /u01/app/grid
chown -R grid.oinstall /u01
```

```
mkdir -p /u01/app/oracle/product/11.2.0/db_1 
chown -R oracle.oinstall  /u01/app/oracle
chmod -R 775 /u01
```


~~配置iscsi连接openfiler存储,此处要根据实际情况设置,这里是一个40G的盘,分成两个20G的区~~
```
yum -y install iscsi-initiator-utils
iscsiadm -m discovery -t sendtargets -p 192.108.26.100:3260
service iscsi restart
```


+ raw the device

```
cat >> /etc/udev/rules.d/60-raw.rules << EOF
ACTION=="add", KERNEL=="/dev/sdb1",RUN+="/bin/raw /dev/raw/raw1 %N"
ACTION=="add", ENV{MAJOR}=="8",ENV{MINOR}=="17",RUN+="/bin/raw /dev/raw/raw1 %M %m"
ACTION=="add", KERNEL=="/dev/sdb2",RUN+="/bin/raw /dev/raw/raw2 %N"
ACTION=="add", ENV{MAJOR}=="8",ENV{MINOR}=="18",RUN+="/bin/raw /dev/raw/raw2 %M %m"
KERNEL=="raw[1-2]", OWNER="grid", GROUP="oinstall", MODE="660"
EOF

start_udev
ls /dev/raw/ -l
```

--- 

### grid_install.rsp

```
oracle.install.responseFileVersion=/oracle/install/rspfmt_crsinstall_response_schema_v11_2_0
ORACLE_HOSTNAME=rac1
INVENTORY_LOCATION=/u01/app/oraInventory
SELECTED_LANGUAGES=en
oracle.install.option=CRS_CONFIG
ORACLE_BASE=/u01/app/grid
ORACLE_HOME=/u01/app/11.2.0/grid
oracle.install.asm.OSDBA=asmdba
oracle.install.asm.OSOPER=
oracle.install.asm.OSASM=asmadmin
oracle.install.crs.config.gpnp.scanName=rac-scan
oracle.install.crs.config.gpnp.scanPort=1521
oracle.install.crs.config.clusterName=rac-cluster
oracle.install.crs.config.gpnp.configureGNS=false
oracle.install.crs.config.gpnp.gnsSubDomain=
oracle.install.crs.config.gpnp.gnsVIPAddress=
oracle.install.crs.config.autoConfigureClusterNodeVIP=false
oracle.install.crs.config.clusterNodes=rac1:rac1-vip,rac2:rac2-vip
oracle.install.crs.config.networkInterfaceList=eth0:10.0.2.0:3,eth1:10.255.255.0:1,eth2:192.168.0.0:2
oracle.install.crs.config.storageOption=ASM_STORAGE
oracle.install.crs.config.sharedFileSystemStorage.diskDriveMapping=
oracle.install.crs.config.sharedFileSystemStorage.votingDiskLocations=
oracle.install.crs.config.sharedFileSystemStorage.votingDiskRedundancy=NORMAL
oracle.install.crs.config.sharedFileSystemStorage.ocrLocations=
oracle.install.crs.config.sharedFileSystemStorage.ocrRedundancy=NORMAL
               	
oracle.install.crs.config.useIPMI=false
oracle.install.crs.config.ipmi.bmcUsername=
oracle.install.crs.config.ipmi.bmcPassword=
oracle.install.asm.SYSASMPassword=
oracle.install.asm.diskGroup.name=DATA
oracle.install.asm.diskGroup.redundancy=EXTERNAL
oracle.install.asm.diskGroup.AUSize=1
oracle.install.asm.diskGroup.disks=/dev/raw/raw1
oracle.install.asm.diskGroup.diskDiscoveryString=
oracle.install.asm.monitorPassword=
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

### db_install.rsp

```
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v11_2_0
oracle.install.option=INSTALL_DB_AND_CONFIG
ORACLE_HOSTNAME=rac1
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=/u01/app/oraInventory
SELECTED_LANGUAGES=en
ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
ORACLE_BASE=/u01/app/oracle
oracle.install.db.InstallEdition=EE
oracle.install.db.EEOptionsSelection=false
oracle.install.db.optionalComponents=
oracle.install.db.DBA_GROUP=dba
oracle.install.db.OPER_GROUP=
oracle.install.db.CLUSTER_NODES=rac1,rac2
oracle.install.db.isRACOneInstall=false
oracle.install.db.racOneServiceName=
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
oracle.install.db.config.starterdb.globalDBName=oradb
oracle.install.db.config.starterdb.SID=orsid
oracle.install.db.config.starterdb.characterSet=AL32UTF8
oracle.install.db.config.starterdb.memoryOption=true
oracle.install.db.config.starterdb.memoryLimit=802
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
oracle.install.db.config.starterdb.storageType=ASM_STORAGE
oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=
oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=
oracle.install.db.config.asm.diskGroup=DATA
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

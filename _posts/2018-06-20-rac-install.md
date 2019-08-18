---
title: "rac silent install"
layout: post
category: linux
---


## [RAC](https://www.linuxidc.com/Linux/2015-10/124127.htm)


### install software

```
yum -y groupinstall "Development Tools"
yum -y install vim screen smartmontools sysstat
yum -y install  gcc gcc-c++ make binutils compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel glibc glibc-common glibc-devel libaio libaio-devel       libgcc libstdc++ libstdc++-devel unixODBC unixODBC-devel
yum -y install xorg-x11-xauth 
rpm -ivh /stage/grid/rpm/cvuqdisk-1.0.9-1.rpm

yum -y install kmod-oracleasm oracleasm-support
rpm -ivh oracleasmlib*rpm
```


---

grid user

```
cat >> ~/.bash_profile << EOF
PS1='\[\e[0;33m\]\u@\h\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[1;37m\]'
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

PATH=$ORACLE_HOME/bin:PATH

alias sqlplus='rlwrap -A sqlplus'
alias rman='rlwrap -A rman'
alias dgmgrl='rlwrap -A dgmgrl'
alias asmcmd='rlwrap -A asmcmd'
EOF
```

---


+ hosts

```
cat >> /etc/hosts << EOF
10.255.255.21   rac1
10.255.255.22   rac2
10.255.255.23   rac1-vip
10.255.255.24   rac2-vip
10.255.255.25   rac-scan
192.168.0.1     rac1-priv
192.168.0.2     rac2-priv

10.255.255.121  stb1
10.255.255.122  stb2
10.255.255.123  stb1-vip
10.255.255.124  stb2-vip
10.255.255.125  stb-scan
192.168.255.21  stb1-priv
192.168.255.22  stb2-priv
EOF

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

change lib name

```
ln -s /lib64/libcap.so.2.16 /lib64/libcap.so.1
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

+ [使用udev的原因,但是12开始淘汰](https://blog.csdn.net/u010098331/article/details/51623371)

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


### [create asmdisk](https://www.oracle.com/linux/downloads/linux-asmlib-rhel6-downloads.html)

```
oracleasm init

oracleasm configure 
ORACLEASM_ENABLED=true
ORACLEASM_UID=grid
ORACLEASM_GID=asmadmin
ORACLEASM_SCANBOOT=true
ORACLEASM_SCANORDER=""
ORACLEASM_SCANEXCLUDE=""
ORACLEASM_USE_LOGICAL_BLOCK_SIZE="false"

oracleasm createdisk DISK1 /dev/sdb1
oracleasm createdisk DISK2 /dev/sdb2
oracleasm createdisk DISK3 /dev/sdb3
oracleasm scandisks
oracleasm listdisks
```



--- 

### grid_install.rsp

```
oracle.install.responseFileVersion=/oracle/install/rspfmt_crsinstall_response_schema_v11_2_0
ORACLE_HOSTNAME=stb1
INVENTORY_LOCATION=/u01/app/oraInventory
SELECTED_LANGUAGES=en
oracle.install.option=CRS_CONFIG
ORACLE_BASE=/u01/app/grid
ORACLE_HOME=/u01/app/11.2.0/grid
oracle.install.asm.OSDBA=asmdba
oracle.install.asm.OSOPER=
oracle.install.asm.OSASM=asmadmin
oracle.install.crs.config.gpnp.scanName=stb-scan
oracle.install.crs.config.gpnp.scanPort=1521
oracle.install.crs.config.clusterName=stb-cluster
oracle.install.crs.config.gpnp.configureGNS=false
oracle.install.crs.config.gpnp.gnsSubDomain=
oracle.install.crs.config.gpnp.gnsVIPAddress=
oracle.install.crs.config.autoConfigureClusterNodeVIP=false
oracle.install.crs.config.clusterNodes=stb1:stb1-vip,stb2:stb2-vip
oracle.install.crs.config.networkInterfaceList=eth0:10.0.2.0:3,eth1:10.255.255.0:1,eth2:192.168.255.0:2
oracle.install.crs.config.storageOption=ASM_STORAGE
oracle.install.crs.config.sharedFileSystemStorage.diskDriveMapping=
oracle.install.crs.config.sharedFileSystemStorage.votingDiskLocations=
oracle.install.crs.config.sharedFileSystemStorage.votingDiskRedundancy=NORMAL
oracle.install.crs.config.sharedFileSystemStorage.ocrLocations=
oracle.install.crs.config.sharedFileSystemStorage.ocrRedundancy=NORMAL
oracle.install.crs.config.useIPMI=false
oracle.install.crs.config.ipmi.bmcUsername=
oracle.install.crs.config.ipmi.bmcPassword=
oracle.install.asm.SYSASMPassword=oracle
oracle.install.asm.diskGroup.name=DATA
oracle.install.asm.diskGroup.redundancy=EXTERNAL
oracle.install.asm.diskGroup.AUSize=1
oracle.install.asm.diskGroup.disks=/dev/oracleasm/disks/DISK1
oracle.install.asm.diskGroup.diskDiscoveryString=/dev/oracleasm/disks/DISK*
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
./runcluvfy.sh stage -pre crsinst -n stb1,stb2 -verbose
```

安装

```
./runInstaller -responseFile /stage/grid/response/grid_install.rsp -silent -ignorePrereq -showProgress
```

注册/安装, 这里注意要先完成node1，再去完成node2，否则sid会乱，而且脑裂争抢OCR

```
As a root user, execute the following script(s):
        1. /u01/app/oraInventory/orainstRoot.sh
        2. /u01/app/11.2.0/grid/root.sh

As install user, execute the following script to complete the configuration.
        1. /u01/app/11.2.0/grid/cfgtoollogs/configToolAllCommands RESPONSE_FILE=response_file_location

```


grid 静默安装后，执行完root安装后会用grid用户再执行一次cfgrsp的密码相关配置
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

### [Clean Up a Failed Grid Infrastruture Installation](https://oracle-base.com/articles/rac/clean-up-a-failed-grid-infrastructure-installation)

#### grid

On all cluster nodes except the last, run the following command as the "root" user.

```
# perl $GRID_HOME/crs/install/rootcrs.pl -verbose -deconfig -force
```

On the last cluster node, run the following command as the "root" user.

```
# perl $GRID_HOME/crs/install/rootcrs.pl -verbose -deconfig -force -lastnode
```

This final command will blank the OCR configuration and voting disk.


#### asm disks


```
# dd if=/dev/zero of=/dev/sdb1 bs=1024 count=100

# /etc/init.d/oracleasm deletedisk DATA /dev/sdb1
# /etc/init.d/oracleasm createdisk DATA /dev/sdb1
```

---


### oracle user

```
cat >> ~/.bash_profile << EOF
PS1='\[\e[0;33m\]\u@\h\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[1;37m\]'
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend
HISTSIZE=30000
HISTFILESIZE=300000
HISTTIMEFORMAT="%F %T "

LANG="en_US.utf8"
LC_ALL="en_US.utf8"
export EDITOR="vim"

export ORACLE_BASE=/u01/app/oracle
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1
export ORACLE_SID=stbsid1
export PATH=$ORACLE_HOME/bin:$PATH
umask 022

alias sqlplus='rlwrap -A sqlplus'
alias dgmgrl='rlwrap -A dgmgrl'
alias rman='rlwrap -A rman'
EOF
```



### db_install.rsp

```
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v11_2_0
oracle.install.option=INSTALL_DB_AND_CONFIG
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
oracle.install.db.config.starterdb.globalDBName=oradb
oracle.install.db.config.starterdb.SID=stbsid
oracle.install.db.config.starterdb.characterSet=AL32UTF8
oracle.install.db.config.starterdb.memoryOption=true
oracle.install.db.config.starterdb.memoryLimit=350
oracle.install.db.config.starterdb.installExampleSchemas=false
oracle.install.db.config.starterdb.enableSecuritySettings=true
oracle.install.db.config.starterdb.password.ALL=oracle
oracle.install.db.config.starterdb.password.SYS=oracle
oracle.install.db.config.starterdb.password.SYSTEM=oracle
oracle.install.db.config.starterdb.password.SYSMAN=oracle
oracle.install.db.config.starterdb.password.DBSNMP=oracle
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
./runcluvfy.sh stage -pre dbinst -n stb1,stb2 -verbose
```

install rdbms

```
./runInstaller -ignorePrereq -silent -force -responseFile /stage/database/response/db_install.rsp -showProgress
```

---

### dbca 

```
$ORACLE_HOME/bin/dbca -silent -createDatabase -templateName General_Purpose.dbc  -gdbName oradb -sid stbsid -sysPassword oracle -systemPassword  oracle -storageType ASM -diskGroupName DATA -datafileJarLocation $ORACLE_HOME/assistants/dbca/templates -nodeinfo stb1,stb2 -characterset AL32UTF8 -obfuscatedPasswords false-sampleSchema -false-asmSysPassword oracle -database files
```

```
dbca -silent -createDatabase -templateName General_Purpose.dbc -gdbname ora11g -sid ora11g -sysPassword lhr -systemPassword lhr -responseFile NO_VALUE -datafileDestination /u01/app/oracle/oradata/ -redoLogFileSize 50 -recoveryAreaDestination /u01/app/oracle/flash_recovery_area -storageType FS -characterSet ZHS16GBK -nationalCharacterSet AL16UTF16 -sampleSchema true -memoryPercentage 30 -totalMemory 200 -databaseType OLTP -emConfiguration NONE
```

```
$ORACLE_HOME/bin/dbca -silent -createDatabase -templateName General_Purpose.dbc  -gdbName www.luocs.com -sid luocs -sysPassword oracle_12345 -systemPassword  oracle_12345 -storageType ASM -diskGroupName MYDATA -datafileJarLocation $ORACLE_HOME/assistants/dbca/templates -nodeinfo rac1,rac2 -characterset AL32UTF8 -obfuscatedPasswords false-sampleSchema false-asmSysPassword Oracle_12345Copying database files
```

---

### cfgrsp

安装完毕后,执行完root安装后会用oracle用户再执行一次cfgrsp的密码相关配置
[Running Postinstallation Configuration Using a Response File](https://docs.oracle.com/cd/E11882_01/install.112/e41961/app_nonint.htm#CWLIN379)


```
cat >> /stage/database/response/pwdrsp.properties << EOF 
oracle.server|S_SYSPASSWORD=oracle
oracle.server|S_SYSTEMPASSWORD=oracle
oracle.server|S_EMADMINPASSWORD=oracle
oracle.server|S_DBSNMPPASSWORD=oracle
oracle.server|S_ASMSNMPPASSWORD=oracle
oracle.server|S_PDBADMINPASSWORD=oracle
EOF
```

```
/u01/app/oracle/product/11.2.0/dbhome_1/cfgtoollogs/configToolAllCommands RESPONSE_FILE=/stage/database/response/pwdrsp.properties
$ORACLE_HOME/cfgtoollogs/configToolAllCommands RESPONSE_FILE=/stage/database/response/pwdrsp.properties
```

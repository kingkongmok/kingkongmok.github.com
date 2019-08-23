---
layout: post
title: "rac 启动"
category: oracle
tags: [oracle, rac]
---


### [Basic Things in RAC](https://dbasanthosh.wordpress.com/2016/01/10/basic-things-in-rac/)


#### **inittab**

**/etc/init/oracle-ohasd.conf** -> respawn -> **/etc/init.d/init.ohasd** 


```
/u01/app/11.2.0/grid/bin/crsctl lsmodules 
Usage:
  crsctl lsmodules {mdns|gpnp|css|crf|crs|ctss|evm|gipc}
 where
   mdns  multicast Domain Name Server
   gpnp  Grid Plug-n-Play Service
   css   Cluster Synchronization Services
   crf   Cluster Health Monitor
   crs   Cluster Ready Services
   ctss  Cluster Time Synchronization Service
   evm   EventManager
   gipc  Grid Interprocess Communications
```

```
crsctl status resource -t -init
```

---

#### **OHASD** Oracle High Availability Services Daemon

相关命令

Enable Automatic start of Oracle High Availability services after reboot

```
crsctl enable has
```

Disable Automatic start of Oracle High Availability services after reboot


OHASD无法kill，一旦kill，立马又会被拉起了

Ohasd spawns 3 types of services at cluster level

Level 1: Cssd Agent
Level 2: Oraroot Agent (respawns cssd, crsd, cttsd, diskmon, acfs)
Level 3: OraAgent(respawns mdsnd, gipcd, gpnpd, evmd, asm), CssdMonitor


```
#To start has services after reboot.
crsctl enable has 

# has services should not start after reboot
crsctl disable has 

# Check configuration whether autostart is enabled or not.
crsctl config has 

# check whether it is enabled or not.
cat /etc/oracle/scls_scr/<Node_name>/root/ohasdstr 

# whether restart enabled if node fails.
cat /etc/oracle/scls_scr/<Node_name>/root/ohasdrun 
```

---

#### **OCR & OLR** Oracle Cluster Registry,  Oracle Local Registry

**OLR** -> ASM -> **OCR**

```
#OCR file backup location
ocrconfig -showbackup 

#OCR Backup
ocrconfig -export < File_Name_with_Full_Location.ocr > 

#Restore OCR
ocrconfig -restore <File_Name_with_Full_Location.ocr> 

#Import metadata specifically for OCR.
ocrconfig -import <File_Name_With_Full_Location.dmp> 

#Gives the OCR info in detail
Ocrcheck -details 

#Gives the OLR info in detail
ocrcheck -local 

#Take the dump of OLR.
ocrdump -local <File_Name_with_Full_Location.olr> 

#Take the dump of OCR.
ocrdump <File_Name_with_Full_Location.ocr> 
```

---

### **Voting Disk**

两个主要作用：

+ 动态 - 心跳信息
+ 静态 - 群集中的节点信息

```
#Taking backup of voting disk
dd if=Name_Of_Voting_Disk of=Name_Of_Voting_Disk_Backup 

#Check voting disk details.
crsctl query css votedisk 

#To add voting disk
crsctl add css votedisk path_to_voting_disk 

#If the Cluster is down
crsctl add css votedisk -force 

#Delete Voting disk
crsctl delete css votedisk <File_Name_With_Password_With_file_name> 

#If the cluster is down
crsctl delete css votedisk -force 

#Replace the voting disk.
crsctl replace votedisk <+ASM_Disk_Group> 
```

---

#### **CRSD** stands for Cluster Resource Service Daemon 

起停服务，及维护**OCR**

```
#Check crs resources
crs_stat -t -v 

#Check in a bit detail view. BEST ONE.
crsctl stat res -t 

#Enable Automatic start of Services after reboot
crsctl enable crs 

#Check crs Services.
crsctl check crs 

#Disable Automatic start of CRS services after reboot
crsctl disable crs 

#Stop the crs services on the node which we are executing
crsctl stop crs 

#Stop the crs services forcefully
crsctl stop crs -f 

#To start the crs services on respective node
crsctl start crs 

#To start the crs services in exclusive mode when u lost voting disk.
#You need to replace the voting disk after you start the css.
crsctl start crs -excl 

#Stop the crs services on the cluster nodes
crsctl stop cluster -all 

#Start the crs services on all the cluster nodes.
crsctl start cluster -all 

#Find all the nodes relative to the cluster
olsnodes 

#With this you will get master node information
oclumon manage -get master 

#Find PID from which crs is running.
cat $CRS_HOME/crs/init/<node_name>.pid 
```

---

#### **CSSD** Cluster Synchronization Service Daemon

如果两个节点都已启动并正在运行。并且由于其中一个通信通道，CSSD进程获得了另一个节点关闭的信息。因此，在这种情况下，无法将新事务分配给该节点。节点驱逐将完成。现在运行的节点将所有权作为主节点。

```
#用于停止css
crsctl stop css 

#重启后禁用自动启动。
crsctl disable css 
```

---

####  **CTTSD** Cluster Time Synchronization Service Daemon

```
#检查所有节点的时钟同步
cluvfy comp clocksync -n all -verbose 
#检查msecs中的服务状态和时间偏移。
crsctl check ctts 
```

--- 

#### **VIP**

```
#To start VIP
srvctl start vip -n <node_name> -i <VIP_Name> 

#To stop VIP
srvctl stop vip -n <node_name> -i <VIP_Name> 

#Enable the VIP.
srvctl enable vip -i vip_name 

#Disable the VIP.
srvctl disable vip -i vip_name 

#status of nodeapps
srvctl status nodeapps -n <node_name> 

#status of vip on a node
srvctl status vip -n <node_name> 
```

---

#### SCAN IP & Listener  Single Client Access Name

**least_recently_loaded算法** -> **SCAN Listener** 

```
#retrieves scan listener configuration
srvctl config scan 

#List of scan listeners with Port number
srvctl config scan_listener 

#Add a scan listener to the cluster
srvctl add scan -n <node_name> 

#to add scan listener on specific port
srvctl add scan_listener -p <Desired_port_number> 

#find the list of scan listeners
SQL> SHOW PARAMETER REMOTE_LISTENER; 

#stops all scan listeners when used without -i option
srvctl stop scan 

#Stops one or more services in the cluster
srvctl stop scan_listener 

#To start the scan VIP
srvctl start scan 

#Start the scan listener.
srvctl start scan_listener 

#verify scan VIP status
srvctl status scan 

#Verify scan listener status.
srvctl status scan_listener 

#Modify the scan listener
srvctl modify scan_listener 

#relocate the scan listener to another node.
srvctl relocate scan_listener -i <Ordinal_Number> -n <node_name> 
```

---

#### **Ologgerd** cluster logger service Daemon

脑裂分辨，主控制器辨别

此过程负责收集本地节点中的信息。这将从每个节点收集信息，并将数据发送到master loggerd。这将发送信息，如CPU，内存使用情况，Os级别信息，磁盘信息，磁盘信息，进程，文件系统信息。 


```
#Find which is the master node
oclumon manage -get master 

#Will get the path of the repository logs
oclumon manage -get reppath 

#This will give you the limitations on repository size
oclumon manage -get repsize 

#find which nodes are connected to loggerd
oclumon showobjects

#This will give a detail view including system, topconsumers, processes, devices, nics, filesystems status, protocol errors.
oclumon dumpnodeview 

#you can view all the details in c. column from a specific time you mentioned.
oclumon dumpnodeview -n <node_1 node_2 node_3> -last "HH:MM:SS" 

#If we need info from all the nodes.11.What is sysmon?
oclumon dumpnodeview allnodes -last "HH:MM:SS" 
```

---

#### **Evmd** Event Volume Manager Daemon


它向集群中的所有其他节点发送和接收有关资源状态更改的操作。这将借助**ONS** Oracle Notification Services

```
#获取evmd中生成的事件。
evmwatch -A -t "@timestamp @@" 
#这将在上述节点的evmd日志中发布消息。
evmpost -u "<message here>" -h <node_name> 
```

---

#### **mdnsd** Multicast Domain Name Service

gpndp使用此过程来定位群集中的配置文件以及GNS以执行名称解析。Mdnsd更新init目录中的pid文件。

---

#### **ONS** Oracle Notification Service


+ SMTP, mail sent
+ nodes之间传输信息

```
#Status of nodeapps
srvctl status nodeapps 

#Check ons configuration.
cat $ORACLE_HOME/opmn/conf/ons.config 

#ONS logs will be in this location.
$ORACLE_HOME/opmn/logs 
```
---

#### **TAF** Trasparent Application Failover

当任何rac节点关闭时，select语句需要故障转移到活动节点。

```
SELECT machine, failover_type, failover_method, failed_over, COUNT(1) FROM gv$session GROUP BY machine, failover_type, failover_method, failed_over;
```

---

#### **GPNPD** Grid Plug aNd Play Daemon

此配置文件由群集名称，主机名，具有IP地址的ntwork配置文件，OCR组成。如果我们对表决磁盘进行任何修改，将更新配置文件。

```
#Check the version of tool.
gpnptool ver 

# get local gpnpd server.
gpnptool lfind 

#read the profile
gpnptool get 

#check daemon is running on local node.
gpnptool lfind 

#Check whether configuration is valid.
gpnptool check -p= CRS_HOME/gpnp/<node_name>/profile/peer/profile.xml 
```

---

#### **FCF**  Fast Connection Failover

它是一个应用程序级故障转移过程。这将自动订阅FAN事件，这将有助于对数据库集群的上下事件做出即时反应。


#### ** GCS(LMSn)** Global Cache Service

它负责在需要时将块从实例传输到另一个实例, 无需从数据文件中选择数据

#### **GES(LMD)** Global Enqueue Service

GES控制所有节点上的库和字典缓存。GES管理事务锁，表锁，库缓存锁，字典缓存锁，数据库安装锁。

#### **GRD** Global Resource Directory

这是为了记录资源和入队的信息。就这个词而言，它存储了所有信息的信息。数据块标识符，数据块模式（共享，独占，空），缓冲区高速缓存等信息将具有访问权限


#### Diskmon 

当ocssd启动时，磁盘监视器守护程序会持续运行。它监视并执行Exadata存储服务器的

#### **OPROCD** Oracle Process Monitor Daemon

就是cssd

#### **FAN** Fast Application Notification

就是ONS


---

## [命令](https://blog.51cto.com/xiaocao13140/1930501)

+ 节点层：osnodes 
+ 网络层：oifcfg 
+ 集群层：crsctl, ocrcheck,ocrdump,ocrconfig 
+ 应用层：srvctl,onsctl,crs_stat 

---

### 节点层

```
grid@stb1 ~ $ $ORACLE_HOME/bin/!!
$ORACLE_HOME/bin/olsnodes -n
stb2    1
stb1    2
```

### 网络层

```
grid@stb1 ~ $ $ORACLE_HOME/bin/oifcfg getif
eth1  10.255.255.0  global  public
eth2  192.168.255.0  global  cluster_interconnect
```


```
[root@rac1 bin]# ./oifcfg setif -global eth0/192.168.1.119:public 
[root@rac1 bin]# ./oifcfg setif -globaleth1/10.85.10.119:cluster_interconnect
[root@rac1 bin]# ./oifcfg getif -type public 
[root@rac1 bin]# ./oifcfg delif -global 
```

### 集群层

```
grid@stb1 ~ $ crsctl status resource -t
grid@stb1 ~ $ crsctl status resource -t -init
```

CRS进程栈默认随着操作系统的启动而自启动，有时出于维护目的需要关闭这个特性，可以用root用户执行下面命令。 

```
[root@rac1 bin]# ./crsctl disable crs 
[root@rac1 bin]# ./crsctl enable crs 
```

这个命令实际是修改了以下两个文件内容,disable后**ohasd.bin reboot**不能启动，也就没有后面的一系列进程。但**/bin/sh /etc/init.d/init.tfa run** 和 **/bin/sh /etc/init.d/init.ohasd run**由init启动。

```
/etc/oracle/scls_scr/$(HOSTNAME)/root/ohasdstr
/etc/oracle/scls_scr/$(HOSTNAME)/root/ohasdrun
```


手动启动crs

```
[root@stb1 bin]# ./crsctl start crs
CRS-4123: Oracle High Availability Services has been started.
```

```
 /u01/app/11.2.0/grid/bin/ohasd.bin reboot
 /u01/app/11.2.0/grid/bin/oraagent.bin
 /u01/app/11.2.0/grid/bin/mdnsd.bin
 /u01/app/11.2.0/grid/bin/gpnpd.bin
 /u01/app/11.2.0/grid/bin/gipcd.bin
 /u01/app/11.2.0/grid/bin/cssdmonitor
 /u01/app/11.2.0/grid/bin/cssdagent
 /u01/app/11.2.0/grid/bin/ocssd.bin 
 /u01/app/11.2.0/grid/bin/orarootagent.bin
 /u01/app/11.2.0/grid/bin/octssd.bin reboot
 /u01/app/11.2.0/grid/bin/evmd.bin
  \_ /u01/app/11.2.0/grid/bin/evmlogger.bin -o /u01/app/11.2.0/grid/evm/log/evmlogger.info -l /u01/app/11.2.0/grid/evm/log/evmlogge
 asm_pmon_+ASM2
 asm_psp0_+ASM2
 asm_vktm_+ASM2
 asm_gen0_+ASM2
 asm_diag_+ASM2
 asm_ping_+ASM2
 asm_dia0_+ASM2
 asm_lmon_+ASM2
 asm_lmd0_+ASM2
 asm_lms0_+ASM2
 asm_lmhb_+ASM2
 asm_mman_+ASM2
 asm_dbw0_+ASM2
 asm_lgwr_+ASM2
 asm_ckpt_+ASM2
 asm_smon_+ASM2
 asm_rbal_+ASM2
 asm_gmon_+ASM2
 asm_mmon_+ASM2
 asm_mmnl_+ASM2
 asm_lck0_+ASM2
 oracle+ASM2 (DESCRIPTION=(LOCAL=YES)(ADDRESS=(PROTOCOL=beq)))
 /u01/app/11.2.0/grid/bin/crsd.bin reboot
 oracle+ASM2_ocr (DESCRIPTION=(LOCAL=YES)(ADDRESS=(PROTOCOL=beq)))
 asm_asmb_+ASM2
 oracle+ASM2_asmb_+asm2 (DESCRIPTION=(LOCAL=YES)(ADDRESS=(PROTOCOL=beq)))
 asm_o000_+ASM2
 oracle+ASM2_o000_+asm2 (DESCRIPTION=(LOCAL=YES)(ADDRESS=(PROTOCOL=beq)))
 /u01/app/11.2.0/grid/bin/oraagent.bin
 /u01/app/11.2.0/grid/bin/orarootagent.bin
 oracle+ASM2 (DESCRIPTION=(LOCAL=YES)(ADDRESS=(PROTOCOL=beq)))
 /u01/app/11.2.0/grid/opmn/bin/ons -d
  \_ /u01/app/11.2.0/grid/opmn/bin/ons -d
 /u01/app/11.2.0/grid/bin/tnslsnr LISTENER 
```


影响 **/etc/oracle/scls_scr/stb1/root/ohasdstr**

```
[root@stb1 bin]# ./crsctl disable has
CRS-4621: Oracle High Availability Services autostart is disabled.
```

效果和 **./crsctl disable crs**相似，就是启动不了。



```
crsctl query css votedisk
##  STATE    File Universal Id                File Name Disk group
--  -----    -----------------                --------- ---------
 1. ONLINE   67fbe885438c4f4cbf85a68076a2aa68 (/dev/oracleasm/disks/DISK1) [DATA]
 Located 1 voting disk(s).
```

#### OCR 的备份

```
grid@stb2 ~ $ ls -lh /u01/app/11.2.0/grid/cdata/stb-cluster/
total 20M
-rw------- 1 root root 6.6M Aug 17 21:41 backup00.ocr
-rw------- 1 root root 6.6M Aug 17 21:41 day.ocr
-rw------- 1 root root 6.6M Aug 17 21:41 week.ocr

grid@stb2 /u01/app/11.2.0/grid/cdata/stb-cluster $ sudo md5sum *
4dc00b7f877a0f0b7aa8fbaa2a91a6aa  backup00.ocr
4dc00b7f877a0f0b7aa8fbaa2a91a6aa  day.ocr
4dc00b7f877a0f0b7aa8fbaa2a91a6aa  week.ocr
```

---

### 应用层

crsctl, srvctl 略

onsctl

---

## srvctl add database


#### standalone db

```
sudo $GRID_HOME/bin/crsctl delete resource  ora.oradb.db
```

####  rac

```
srvctl add database -d db_unique_name -r PRIMARY -n db_name -o $ORACLE_HOME 
srvctl add instance -d db_unique_name -i $ORACLE_SID -n $HOSTNAME
srvctl add instance -d db_unique_name -i $ORACLE_SID -n $HOSTNAME
```


```
srvctl add database -d db_unique_name -o ORACLE_HOME [-x node_name] [-m domain_name] [-p spfile] [-r {PRIMARY|PHYSICAL_STANDBY|LOGICAL_STANDBY|SNAPSHOT_STANDBY}] [-s start_options] [-t stop_options] [-n db_name] [-y {AUTOMATIC|MANUAL}] [-g server_pool_list] [-a "diskgroup_list"]

srvctl modify database -d db_unique_name [-n db_name] [-o ORACLE_HOME] [-u oracle_user] [-m domain] [-p spfile] [-r {PRIMARY|PHYSICAL_STANDBY|LOGICAL_STANDBY|SNAPSHOT_STANDBY}] [-s start_options] [-t stop_options] [-y {AUTOMATIC|MANUAL}] [-g "server_pool_list"] [-a "diskgroup_list"|-z]

srvctl add service -d db_unique_name -s service_name -r preferred_list [-a available_list] [-P {BASIC|NONE|PRECONNECT}]
[-l [PRIMARY|PHYSICAL_STANDBY|LOGICAL_STANDBY|SNAPSHOT_STANDBY]
[-y {AUTOMATIC|MANUAL}] [-q {TRUE|FALSE}] [-j {SHORT|LONG}]
[-B {NONE|SERVICE_TIME|THROUGHPUT}] [-e {NONE|SESSION|SELECT}]
[-m {NONE|BASIC}] [-x {TRUE|FALSE}] [-z failover_retries] [-w failover_delay]
```


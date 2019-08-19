---
layout: post
title: "rac 启动"
category: oracle
tags: [oracle, rac]
---


### [Basic Things in RAC](https://dbasanthosh.wordpress.com/2016/01/10/basic-things-in-rac/)


#### inittab

**/etc/init/oracle-ohasd.conf** -> respawn -> **/etc/init.d/init.ohasd** 

相关命令

Enable Automatic start of Oracle High Availability services after reboot

```
crsctl enable has
```

Disable Automatic start of Oracle High Availability services after reboot

```
crsctl disable has 
```

---

#### Oracle High Availability Services Daemon(OHASD) 


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

#### OCR & OLR Oracle Cluster Registry,  Oracle Local Registry

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

### Voting Disk

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

#### CRSD stands for Cluster Resource Service Daemon 

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

#### CSSD Cluster Synchronization Service Daemon

如果两个节点都已启动并正在运行。并且由于其中一个通信通道，CSSD进程获得了另一个节点关闭的信息。因此，在这种情况下，无法将新事务分配给该节点。节点驱逐将完成。现在运行的节点将所有权作为主节点。

```
#用于停止css
crsctl stop css 

#重启后禁用自动启动。
crsctl disable css 
```

---

####  CTTSD Cluster Time Synchronization Service Daemon

```
#检查所有节点的时钟同步
cluvfy comp clocksync -n all -verbose 
#检查msecs中的服务状态和时间偏移。
crsctl check ctts 
```

--- 

#### VIP

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
Oclumon manage -get master 

#Will get the path of the repository logs
oclumon manage -get reppath 

#This will give you the limitations on repository size
oclumon manage -get repsize 

#find which nodes are connected to loggerd
Oclumon showobjects

#This will give a detail view including system, topconsumers, processes, devices, nics, filesystems status, protocol errors.
Oclumon dumpnodeview 

#you can view all the details in c. column from a specific time you mentioned.
oclumon dumpnodeview -n <node_1 node_2 node_3> -last “HH:MM:SS” 

#If we need info from all the nodes.11.What is sysmon?
oclumon dumpnodeview allnodes -last “HH:MM:SS” 
```

---

#### **Evmd** Event Volume Manager Daemon


它向集群中的所有其他节点发送和接收有关资源状态更改的操作。这将借助**ONS** Oracle Notification Services

```
#获取evmd中生成的事件。
evmwatch -A -t “@timestamp @@” 
#这将在上述节点的evmd日志中发布消息。
Evmpost -u“<Message here>” - h <node_name> 
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
SELECT machine, failover_type, failover_method, failed_over, COUNT(*) FROM gv$session GROUP BY machine, failover_type, failover_method, failed_over;
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





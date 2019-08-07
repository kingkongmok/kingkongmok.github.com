---
layout: post
title: "oracle change hostname"
category: linux
tags: [oracle]
---

###  [change hostname](https://dbawiki.wordpress.com/2012/10/24/hostname-change-at-linux-with-oracle-db/)


+ Change the host name properly:

```
/etc/hosts
/etc/sysconfig/network
/etc/hostname
```

马上生效

```
# sysctl kernel.hostname=NEW_HOSTNAME
```

+ Change the hostname in tnsnames.ora and listener.ora:

```
$ORACLE_HOME/network/admin/tnsnames.ora
$ORACLE_HOME/network/admin/listener.ora
```

+ Change the hostname in emd.properties:

```
$ORACLE_HOME/sysman/config/emd.properties
```

+ Reboot
+ Restart the listener manually:

```
lsnrctl stop
lsnrctl start
lsnrctl status
```

+ Recreate EM repository:

```
emca -deconfig dbcontrol db -repos drop
emca -config dbcontrol db -repos create
```


---

###  [database global name](https://asktom.oracle.com/pls/apex/f?p=100:11:9676031980070::::P11_QUESTION_ID:9534418000346286724)

需留意**GLOBAL_NAME**和**db_domain**

```
SQL> ALTER DATABASE RENAME GLOBAL_NAME TO <New_Global_Name> ;
SQL> alter system set db_domain='<new_domain_name>' scope=spfile;
```

还有**db_link**
最后还有**DBA_REGISTERED_SNAPSHOTS**

```
SQL> select name, owner, SNAPSHOT_SITE from DBA_REGISTERED_SNAPSHOTS;

NAME OWNER SNAPSHOT_SITE
--------------------------------------------------------------------------------------------------------------------
MGMT_ECM_MD_ALL_TBL_COLUMNS SYSMAN <current_global_database_name>
COST_OBJECT_HIERARCHY_MV TSF_DIM <current_global_database_name>
CURRENCY_MV TSF_DIM <current_global_database_name>
```


---

### [Could not contact High Availability Services](https://blog.xuite.net/gem083/dba/221685456-How+to+Reconfigure+Oracle+HAS+%28High+Availability+Services%29+after+changing+hostname%3F)



issues:

```
[grid@adg2 ~]$ crsctl check has
CRS-4639: Could not contact High Availability Services
CRS-4000: Command Start failed, or completed with errors.
```


用root执行 **/u01/app/oracle/product/11.2.0/dbhome_1/crs/install/roothas.pl** ，重新注册OCR文件

```
grid@adg2 ~ $ readlink -f $ORACLE_HOME/crs/install/roothas.pl
/u01/app/grid/product/11.2.0/grid/crs/install/roothas.pl

root@adg2 ~ # /u01/app/grid/product/11.2.0/grid/crs/install/roothas.pl
Using configuration parameter file: /u01/app/grid/product/11.2.0/grid/crs/install/crsconfig_params
LOCAL ADD MODE 
Creating OCR keys for user 'grid', privgrp 'oinstall'..
Operation successful.
LOCAL ONLY MODE 
Successfully accumulated necessary OCR keys.
Creating OCR keys for user 'root', privgrp 'root'..
Operation successful.
CRS-4664: Node adg2 successfully pinned.
Adding Clusterware entries to upstart
```

检查has

```
grid@adg2 ~ $ crsctl config has
CRS-4622: Oracle High Availability Services autostart is enabled. 
```

开启、注册相应程序

```
crsctl start res "ora.cssd"
```

注册listener

```
srvctl add listener -l LISTENER
srvctl start listener
```

注册asm

```
srvctl add asm -l LISTENER -p $ORACLE_HOME/dbs/spfile${ORACLE_SID}.ora
srvctl add asm -l LISTENER -p /u01/app/grid/product/11.2.0/grid/dbs/spfile+ASM.ora
crsctl start resource ora.asm
```

这里稍稍注意，spfile的名称不一定，用strings文件查询一下看看是哪个spfile

```
srvctl start asm
```


#### 确认diskgroup挂载了

```
SQL> select state, name, type from v$asm_diskgroup;

STATE       NAME                           TYPE
----------- ------------------------------ ------
DISMOUNTED  DATA
```

```
SQL> col PATH format a40
SQL> select GROUP_NUMBER,MOUNT_STATUS,STATE,REDUNDANCY,NAME,PATH from v$asm_disk; 
SQL> alter diskgroup DATA mount ; 
```

最后oracle用户注册服务

```
srvctl add database -d $ORACLE_SID -o $ORACLE_HOME -p $ORACLE_HOME/dbs/spfile${ORACLE_SID}.ora -s open -t immediate -a "DATA"
```

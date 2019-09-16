---
layout: post
title: "添加DataGuand standby节点"
category: oracle
tags: [oracle, dg]
---


### pridb修改参数

从原来dg添加一个**adg1 DG_CONFIG=(oradb,dg)** 改为 **DG_CONFIG=(oradb,dg,adg1)**

```
alter system set LOG_ARCHIVE_CONFIG='DG_CONFIG=(oradb,dg,adg1)' sid='*' scope=both;
```

添加一个LOG_ARCHIVE_DEST

```
alter system set LOG_ARCHIVE_DEST_3='SERVICE=adg1 LGWR ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=adg1' sid='*' scope=both;
```

---

###  stbydb的设置， 先将recovery、fal、log、name的参数设置好


spfile 并开启到nomount

```
cat > ~/init.ora <<EOF
*.compatible='11.2.0.4.0'
*.control_files='+DATA/adg1/controlfile/current.256.1013424367'
*.db_recovery_file_dest='+DATA'
*.db_recovery_file_dest_size=10G
*.db_name='oradb'
*.memory_max_target=400M
*.memory_target=400M
*.db_unique_name='adg1'
*.db_file_name_convert='+DATA','+DATA'
*.fal_client=adg1
*.fal_server=oradb
*.log_archive_config='DG_CONFIG=(adg1,oradb)'
*.log_archive_dest_1='LOCATION=USE_DB_RECOVERY_FILE_DEST VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=adg1'
*.log_archive_dest_2='SERVICE=oradb LGWR ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=oradb'
*.log_file_name_convert='+DATA','+DATA','+ARCH','+ARCH'
EOF
```

```
SQL> startup nomount pfile='/home/oracle/init.ora';
```

静态监听
增加静态监听， 修改 grid的 $ORACLE_HOME/network/admin/listener.ora，添加以下内容

```
SID_LIST_LISTENER =
  (SID_LIST =
      (SID_DESC =
           (ORACLE_HOME = /u01/app/oracle/product/11.2.0/dbhome_1)
                (SID_NAME = oradg)
                (GLOBAL_DBNAME=dg)
       )
   )
```

---

### db duplicate with rman auxiliary

用于rman的auxiliary(clone from source instance to auxiliary instance), 这里需要1、nomount状态、并且开启监听（也就是静态）

```
$ rman target sys/oracle@oradb auxiliary sys/oracle@adg1
SQL> startup nomount pfile='/home/oracle/init.ora';
RMAN> duplicate target database for standby from active database nofilenamecheck;
SQL> alter database add standby logfile;
```

完成

```
SQL> alter database open;
SQL> recover managed standby database using current logfile disconnect from session;
SQL> alter database recover managed standby database cancel;
SQL> shutdown immediate
```


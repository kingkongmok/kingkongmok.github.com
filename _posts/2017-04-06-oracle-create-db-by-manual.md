---
layout: post
title: "OracleDB 手工建库"
category: oracle
tags: [oracle]
---


## [参考](https://www.oracle-dba-online.com/creating_the_database.htm)



#### create pfile

```
cat > init.ora <<EOF
DB_NAME=ORADB
DB_BLOCK_SIZE=8192
CONTROL_FILES='/u01/app/oracle/oradata/ORADB/controlfileORADR.ctl','/u01/app/oracle/flash_recovery_area/ORADB/controlfileORADR.ctl'
UNDO_TABLESPACE=UNDOTBS
UNDO_MANAGEMENT=AUTO
SGA_TARGET=500M
PGA_AGGREGATE_TARGET=100M
LOG_BUFFER=5242880
DB_RECOVERY_FILE_DEST=/u01/app/oracle/flash_recovery_area
DB_RECOVERY_FILE_DEST_SIZE=2G
EOF
```

#### create createdb.sql.


```
cat > createdb.sql <<EOF
create database ORADB
    CHARACTER SET AL32UTF8
    DATAFILE '/u01/app/oracle/oradata/ORADB/sys.dbf' size 500M 
    SYSAUX datafile '/u01/app/oracle/oradata/ORADB/sysaux.dbf' size 100m 
    UNDO tablespace UNDOTBS datafile '/u01/app/oracle/oradata/ORADB/undo.dbf' size 100m 
    default temporary tablespace TEMP tempfile '/u01/app/oracle/oradata/ORADB/tmp.dbf' size 100m 
    logfile
            group 1 '/u01/app/oracle/oradata/ORADB/log1.log' size 50m, 
            group 2 '/u01/app/oracle/oradata/ORADB/log2.log' size 50m, 
            group 3 '/u01/app/oracle/oradata/ORADB/log3.log' size 50m; 
EOF
```

#### sql

```
startup nomount pfile='/home/oracle/init.ora';
@/home/oracle/createdb.sql
create tablespace users datafile '/u01/app/oracle/oradata/ORADB/user01.dbf' size 100m;
create spfile from pfile='/home/oracle/init.ora';
-- creates all the data dictionary views,
@?/rdbms/admin/catalog.sql
-- creates system specified stored procedures
@?/rdbms/admin/catproc.sql
-- creates the default roles and profiles.
@?/rdbms/admin/pupbld.sql
-- The utlrp.sql script can be called to recompile all objects within the database 
@?/rdbms/admin/utlrp.sql
alter user sys identified by oracle ;
alter user system identified by oracle ;
CREATE USER SCOTT IDENTIFIED BY scott DEFAULT TABLESPACE users PROFILE DEFAULT ACCOUNT UNLOCK;
GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE VIEW TO SCOTT;
GRANT CONNECT, RESOURCE TO SCOTT ;
GRANT UNLIMITED TABLESPACE TO SCOTT;
```

---

#### 添加listener

```
cat >> $ORACLE_HOME/network/admin/listener.ora <<EOF
SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
     (ORACLE_HOME = /u01/app/oracle/product/11.2.0/dbhome_1)
     (SID_NAME = ORADR )
     (GLOBAL_DBNAME= ORADB )
    )
 )
EOF
```


oracle password file

```
orapwd file=${ORACLE_HOME}/dbs/orapwORADR password=oracle
```


#### srvctl config

```
srvctl remove database -d oradr
srvctl add database -d ORADR -o /u01/app/oracle/product/11.2.0/dbhome_1
```



---
layout: post
title: "oracle redefinition big table"
category: linux
tags: [oracle, flashback]
---

## flashback


**db_flashback_retention_target** 单位是 minutes
**undo_retention**   单位是 seconds

---

### flashback database, depends on flashback logs

```
select to_char(oldest_flashback_scn), oldest_flashback_time from v$flashback_database_log;
STARTUP MOUNT force;
FLASHBACK DATABASE TO SCN 411010;
ALTER DATABASE OPEN read only;
query xxx;
startup mount force;
FLASHBACK DATABASE TO SCN 411110;


alter database open resetlogs;
alter database flashback off;
alter database flashback on;
```


```
CREATE RESTORE POINT before_update GUARANTEE FLASHBACK DATABASE;
LIST RESTORE POINT ALL;
FLASHBACK DATABASE TO RESTORE POINT 'BEFORE_UPDATE';
ALTER DATABASE OPEN RESETLOGS;
```



### flashback drop , depends on recyclebin

```
show recyclebin;
flash back table test to before drop;
# 需要更改index和constraint名称, 并重建fk
alter index xxxx rename to pk_test;
alter table test rename constraint xxx to pk_test;
```

Flashback Drop注意事项

. 只能用于非系统表空间和本地管理的表空间。 在系统表空间中，表对象删除后就真的从系统中删除了，而不是存放在回收站中。
. 对象的参考约束不会被恢复，指向该对象的外键约束需要重建。
. 对象能否恢复成功，取决于对象空间是否被覆盖重用。
. 当删除表时，依赖于该表的物化视图也会同时删除，但是由于物化视图并不会放入recycle binzhong，因此当你执行flashback drop时，并不能恢复依赖其的物化视图。需要DBA手工重建。
. 对于回收站（Recycle Bin）中的对象，只支持查询。不支持任何其他DML、DDL等操作。


---

##  flashback query, depends on undo

```
select * from test as of timestamp to_date('2020-08-13 13:00:00', 'yyyy-mm-dd hh24:mi:ss');
select * from test as of scn 9999;
create table test_hist as select * from test as of scn 9999;
```

---

## flashback table, depends on undo

```
alter table test enable row movement;
flashback table test to timestamp to_date('2020-08-13 13:00:00', 'yyyy-mm-dd hh24:mi:ss');
flashback table test to scn 9999;
```

---


## flashback versions, depends on undo

```
-- logminder on
select supplemental_log_data_min from v$database;
-- get the scn versions between
SELECT to_char(versions_startscn), to_char(versions_endscn), versions_xid, versions_operation, id FROM test versions between scn minvalue and maxvalue;
select to_char(versions_startscn), to_char(versions_endscn), versions_xid, versions_operation, id FROM test versions between timestamp to_date(sysdate - 1/24*2) and to_date(sysdate);
```

---

##  flashback archive, depends on undo

```
--check
select * from dba_flashback_archive_ts;
select * from dba_flashback_archive;
--创建flashback archive专用tablespace，创建方案使用此tablespace，将表关联到此方案。
createte tablespace flasharc datafile ;
create flashback archive flashback_archive tablespace flasharc retention 1 year;
-- 将其设置成default，有点类似default tablespace
alter flashback archive flashback_archive set default ;
-- 设置表格实现flashback archive 
alter table table_name flashback archive flashback_archive ; -- 如果没有默认flashback archive
alter table table_name flashback archive ; -- 如果有默认 flashback archive
-- 表只能截不能删，ORA-55610，如果需要取消，则 设置表格取消 flashback archive
alter table table_name no flashback archive;
```

---

## flashback transaction, depends on undo,redo,archivlog

```
desc flashback_transaction_query
select xid, LOGON_USER, OPERATION from flashback_transaction_query where xid='09001600AC0C0000';
select UNDO_SQL from flashback_transaction_query where xid=hextoraw('09001600AC0C0000');
```



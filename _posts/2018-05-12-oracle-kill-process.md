---
layout: post
title: "Oracle查杀进程"
category: oracle
tags: [oracle, health]
---

### sid

**V$SESSION.SID**  and **V$SESSION.SERIAL#** are database process id
**V$PROCESS.SPID**  Shadow process id on the database server
**V$SESSION.PROCESS**  Client process id


###  观察超过1分钟以上的holder会话 (holder不能被查询sql_id)

```
SELECT l.inst_id,DECODE(l.request,0,'Holder: ','Waiter: ')||l.sid sid ,s.serial#, s.machine, s.program,to_char(s.logon_time,'yyyy-mm-dd hh24:mi:ss'),l.id1,  l.id2, l.lmode, l.request, l.type, s.sql_id,s.sql_child_number, s.prev_sql_id,s.prev_child_number
FROM gV$LOCK l , gv$session s
 WHERE (l.id1, l.id2, l.type) IN (SELECT id1, id2, type FROM GV$LOCK WHERE request>0)
 and l.inst_id=s.inst_id and l.sid=s.sid
ORDER BY l.inst_id,l.id1, l.request
/
```

---

### get session, spid is OS process id.

```
COLUMN spid FORMAT A10
COLUMN username FORMAT A10
COLUMN MACHINE FORMAT A25
COLUMN program FORMAT A25
SELECT s.inst_id, s.sid, s.serial#, s.sql_id, p.spid, s.username, s.machine, s.program
FROM   gv$session s
       JOIN gv$process p ON p.addr = s.paddr AND p.inst_id = s.inst_id
WHERE  s.type != 'BACKGROUND'
and s.sid='&sid'
/

   INST_ID        SID    SERIAL# SQL_ID        SPID       USERNAME   PROGRAM
---------- ---------- ---------- ------------- ---------- ---------- ---------------------------------------------
         1        141      21812 d7y679cgur3qq 17274      SCOTT      sqlplus@f1259e845a55 (TNS V1-V3)
```

---

### SQL ordered by Elapsed Time in 20mins, like awr

```
col EXEs format a5;
col TOTAL_ELAPSED format a15;
col ELAPSED_PER_EXEC format a15;
col TOTAL_CPU format a15;
col CPU_PER_SEC format a15;
col TOTAL_USER_IO format a15;
col USER_IO_PER_EXEC format a15;
col MODULE format a20;
select * from (
    select
    SQL_ID,
    EXECUTIONS EXEs,
    -- in second
    round(ELAPSED_TIME/1000000,2) TOTAL_ELAPSED,
    round(ELAPSED_TIME/1000000/nullif(executions, 0) ,2) ELAPSED_PER_EXEC,
    round(CPU_TIME/1000000,2) TOTAL_CPU,
    round(CPU_TIME/1000000/nullif(executions, 0) ,2) CPU_PER_SEC,
    round(user_io_wait_time/1000000,2) TOTAL_USER_IO,
    round(user_io_wait_time/1000000/nullif(executions, 0) ,2) USER_IO_PER_EXEC,
    to_char(LAST_ACTIVE_TIME , 'hh24:mm:ss') LAST_ACTIVE_TIME,
    module
    from gv$sqlarea a where
    LAST_ACTIVE_TIME >=  (sysdate - 20/60*24)
    order by TOTAL_USER_IO desc)
where ROWNUM < 6
/
```

---

###  查询PGA，操过20MB的进程

```
column pgA_ALLOC_MEM format 99,990
column PGA_USED_MEM format 99,990
column inst_id format 99
column username format a15
column program format a25
column logon_time format a25
column SPID format a15
select s.inst_id, s.sid, s.serial#, p.spid, s.machine, s.username, s.logon_time, s.program, PGA_USED_MEM/1024/1024 PGA_USED_MEM, PGA_ALLOC_MEM/1024/1024     PGA_ALLOC_MEM from gv$session s , gv$process p Where s.paddr = p.addr and s.inst_id = p.inst_id and PGA_USED_MEM/1024/1024 > 20 and s.username is not null   order by PGA_USED_MEM;
--

INST_ID        SID    SERIAL# SPID            USERNAME        LOGON_TIME                PROGRAM                   PGA_USED_MEM PGA_ALLOC_MEM
------- ---------- ---------- --------------- --------------- ------------------------- ------------------------- ------------ -------------
      1       3764          1 10855                           2018-10-12_12:14:28       oracle@cdb1 (ARC7)           52            56
      1       1990      22249 26260           CKS             2018-10-19_10:19:34       JDBC Thin Client                    83            92
      1       3559      60977 54081           CKS             2018-10-19_11:00:45       JDBC Thin Client                   209           218

```

---

### select event

```
set lines 150
col event for a50
set pages 1000
col username for a30
select inst_id,username,event,count(*) from gv$session where wait_class#<>6 group by inst_id,username,event order by 1,3 desc;
select inst_id,username,event,sql_id,count(*) from gv$session where wait_class#<>6 group by inst_id,username,event,sql_id order by 1,5;
```

---

### 进程的查杀


```
select sql_fulltext from gv$sqlarea where sql_id='&sql_id';
select sid,serial#, user, machine from gv$session where sql_id='&sql_id' and status='ACTIV';
SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id',0));
```

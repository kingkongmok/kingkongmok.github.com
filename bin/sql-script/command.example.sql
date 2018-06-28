-- Spool on/off
spool /tmp/out.txt;
spool off;

set linesize 9999
set pagesize 100
col 1 format a15


-- startup  启动数据库实例
sqlplus / as sysdba
startup


-- shutdown 关闭数据库实例：
sqlplus / as sysdba
shutdown immediate
shutdown abort


-- start listener  启动监听
$ lsnrctl start
$ lsnrctl status
$ lsnrctl stop


-- EM/oem start 
$ emctl start dbconsole
$ emctl stop dbconsole


-- sid / service name / user
show parameter;
show parameter service;
show parameter service_name;
select instance from v$thread;
select name from v$database;
select user from dual;
select sys_context('userenv','instance_name') from dual;
SELECT sys_context('USERENV', 'SID') FROM DUAL;


-- server ip and hostname
select utl_inaddr.get_host_address(host_name), host_name from v$instance;
-- client ip and hostname
select sys_context('USERENV', 'HOST') from dual;
select sys_context('USERENV', 'IP_ADDRESS') from dual;


-- show oracle version
SELECT * FROM V$VERSION;


-- which spfile
show parameter spfile;


-- show schemas
select distinct owner from dba_segments where owner in (select username from dba_users where default_tablespace not in ('SYSTEM','SYSAUX') );


-- list objects
-- Tables
select TABLE_NAME, OWNER from SYS.ALL_TABLES order by OWNER, TABLE_NAME;
-- Schemas
select USERNAME from SYS.ALL_USERS order by USERNAME;
-- Views
select VIEW_NAME, OWNER from SYS.ALL_VIEWS order by OWNER, VIEW_NAME;
-- Packages
select OBJECT_NAME, OWNER from SYS.ALL_OBJECTS where UPPER(OBJECT_TYPE) = 'PACKAGE' order by OWNER, OBJECT_NAME; 
-- Procedures
select OBJECT_NAME, OWNER from SYS.ALL_OBJECTS where upper(OBJECT_TYPE) = upper('PROCEDURE') order by OWNER, OBJECT_NAME;
-- Procedure Columns
select OWNER, OBJECT_NAME, ARGUMENT_NAME, DATA_TYPE, IN_OUT from SYS.ALL_ARGUMENTS order by OWNER, OBJECT_NAME, SEQUENCE;
-- Functions
select OBJECT_NAME, OWNER from SYS.ALL_OBJECTS where upper(OBJECT_TYPE) = upper('FUNCTION') order by OWNER, OBJECT_NAME;
-- Triggers
select TRIGGER_NAME, OWNER from SYS.ALL_TRIGGERS order by OWNER, TRIGGER_NAME 
-- Indexes
select INDEX_NAME, TABLE_NAME, TABLE_OWNER from SYS.ALL_INDEXES order by TABLE_OWNER, TABLE_NAME, INDEX_NAME;



-- change password
ALTER USER user_name IDENTIFIED BY NEWPASSWORD;
-- change user unlock
ALTER USER user_name account unlock;

-- show tables
SELECT owner, table_name FROM dba_tables;
SELECT owner, table_name FROM all_tables;
SELECT table_name FROM user_tables;
SELECT table_name FROM dba_tables WHERE owner='HR';

-- DG http://www.dba-oracle.com/t_physical_standby_missing_log_scenario.htm

-- current | standby
select CONTROLFILE_TYPE from v$database; 

-- PRIMARY | PHYSICAL STANDBY
select database_role from v$database;

-- 'MOUNTED', your database is mounted.
-- 'READ WRITE', then you can assume it's been activated.
-- 'READ ONLY' then it might be opened for query in read only mode, but not activated.
-- 'READ ONLY WITH APPLY' when using active dataguard.
SELECT open_mode FROM v$database;

-- current_scn
SELECT to_char(CURRENT_SCN) FROM V$DATABASE;


-- oracle fal parameter.
show parameter fal_client;
show parameter fal_server;


-- show active archive log destinations 
archive log list;
show parameter db_recovery_file_dest
select dest_name,status,destination from V$ARCHIVE_DEST;
show parameter recover
show parameter log_archive_dest


-- Check ADG status of sync to standby https://community.oracle.com/thread/2228773
SELECT THREAD#, MAX(SEQUENCE#) FROM V$LOG_HISTORY GROUP BY THREAD#;

   THREAD#                          MAX(SEQUENCE#)
---------- ---------------------------------------
         1                                   19413
         2                                   21242


-- ADG status; 观察status，看看MRP0是否有waiting的出现（有的话异常）
select process, status, thread#, sequence#  from v$managed_standby where STATUS<>'IDLE';

PROCESS   STATUS          THREAD#  SEQUENCE#
--------- ------------ ---------- ----------
ARCH      CLOSING               1      85682
ARCH      CLOSING               1      85681
ARCH      CONNECTED             0          0
ARCH      CLOSING               2      54360
MRP0      APPLYING_LOG          1      85683


-- on slave, V$DATAGUARD_STATS
col VALUE format a20
col NAME format a25
col UNIT format  a35
col TIME_COMPUTED format a30
col DATUM_TIME format a30

select * from V$DATAGUARD_STATS;
select VALUE from V$DATAGUARD_STATS where NAME = 'transport lag';
select VALUE from V$DATAGUARD_STATS where NAME = 'apply lag';
select to_number(substr(value,2,2))*1440 + to_number(substr(value,5,2))*60 + to_number(substr(value,8,2)) from V$DATAGUARD_STATS;


-- on master, dg gap
select * from v$archive_gap;


-- check oracle health
-- activesession (zabbix)
Select count(1) From gv$session where status='ACTIVE';
-- locked (zabbix)
select count(1) from gv$locked_object;
-- process (zabbix)
select count(1) from gv$process;
-- get TableSpace info (zabbix)
select TABLESPACE_NAME, round(USED_PERCENT,0) used, round(100-USED_PERCENT,0) free, TABLESPACE_SIZE from DBA_TABLESPACE_USAGE_METRICS;
-- ASM info (zabbix)
select name,total_mb,total_mb-free_mb used_mb,free_mb,round((total_mb-free_mb)/total_mb,3)*100 "used_rate(%)" from v$asm_diskgroup;


-- connected session;
SELECT SID, SERIAL#, MACHINE FROM gv$SESSION;

-- check session and process, get PID
select s.sid, s.serial#, p.spid processid, s.process clientpid from gv$process p, gv$session s where p.addr = s.paddr 


-- count process.
select count(*) from gv$process;
select value from v$parameter where name ='processes' ;


-- event_names
col WAIT_CLASS format a15                                                          
SELECT wait_class#,wait_class_id,wait_class,COUNT(1) AS "count" FROM gv$event_name GROUP BY wait_class#, wait_class_id, wait_class ORDER BY wait_class#;     
--
--
WAIT_CLASS# WAIT_CLASS_ID WAIT_CLASS	       count
----------- ------------- --------------- ----------
	  0    1893977003 Other 		 958
	  1    4217450380 Application		  17
	  2    3290255840 Configuration 	  24
	  3    4166625743 Administrative	  55
	  4    3875070507 Concurrency		  33
	  5    3386400367 Commit		   2
	  6    2723168908 Idle			  96
	  7    2000153315 Network		  35
	  8    1740759767 User I/O		  48
	  9    4108307767 System I/O		  32
	 10    2396326234 Scheduler		   8



-- get CURRENT session 
col OBJECT_NAME format a20
select object_name, session_id, 
decode(LMODE,
    0, 'None',
    1, 'Null',
    2, 'Row-S (SS)',
    3, 'Row-X (SX)',
    4, 'Share',
    5, 'S/Row-X (SSX)',
    6, 'Exclusive') lock_type ,        -- lock mode in which session holds lock
decode(REQUEST,
    0, 'None',
    1, 'Null',
    2, 'Row-S (SS)',
    3, 'Row-X (SX)',
    4, 'Share',
    5, 'S/Row-X (SSX)',
    6, 'Exclusive') lock_requested ,
block, 
ctime         -- Time since current mode was granted
from gv$locked_object, all_objects, gv$lock where gv$locked_object.object_id = all_objects.object_id AND
gv$lock.id1 = all_objects.object_id AND gv$lock.sid = gv$locked_object.session_id order by session_id, ctime desc, object_name ;
--
--
OBJECT_NAME	     SESSION_ID LOCK_TYPE     LOCK_REQUESTE	 BLOCK	    CTIME
-------------------- ---------- ------------- ------------- ---------- ----------
RP_EXCH_RATE		   2210 Row-X (SX)    None		     2		1
RP_FREIGHT		   2210 Row-X (SX)    None		     2		1
RP_FREIGHT_CONFIRM	   2210 Row-X (SX)    None		     2		1
RP_FREIGHT_CONFIRM_D	   2210 Row-X (SX)    None		     2		1



--  查看锁
select * from gv$lock where type in ('tx', 'tm');


-- use asmcmd
$ . ./profle_grid
$ asmcmd


-- check asm disk
select GROUP_NUMBER,DISK_NUMBER,STATE,MOUNT_STATUS,REDUNDANCY, TOTAL_MB,FREE_MB,VOTING_FILE from v$asm_disk;

GROUP_NUMBER DISK_NUMBER STATE			  MOUNT_STATUS		REDUNDANCY		TOTAL_MB    FREE_MB VOT
------------ ----------- ------------------------ --------------------- --------------------- ---------- ---------- ---
	   1	       0 NORMAL 		  CACHED		UNKNOWN 		  511993     301476 N
	   1	       1 NORMAL 		  CACHED		UNKNOWN 		  511993     301521 N
	   2	       0 NORMAL 		  CACHED		UNKNOWN 		  511993     382892 N
	   2	       1 NORMAL 		  CACHED		UNKNOWN 		  511993     382894 N
	   2	       2 NORMAL 		  CACHED		UNKNOWN 		  511993     382898 N
	   2	       3 NORMAL 		  CACHED		UNKNOWN 		  511993     382912 N
	   2	       4 NORMAL 		  CACHED		UNKNOWN 		  511993     382895 N
	   3	       0 NORMAL 		  CACHED		UNKNOWN 		    1023	715 Y
	   3	       1 NORMAL 		  CACHED		UNKNOWN 		    1023	713 Y
	   3	       2 NORMAL 		  CACHED		UNKNOWN 		    1023	715 Y


-- asm group info
col name format a20;
select name,total_mb,total_mb-free_mb used_mb,free_mb,round((total_mb-free_mb)/total_mb,3)*100 "used_rate(%)" from v$asm_diskgroup;

NAME		       TOTAL_MB    USED_MB    FREE_MB used_rate(%)
-------------------- ---------- ---------- ---------- ------------
ARCDG1			1023986     420989     602997	      41.1
DATADG1 		2559965     645474    1914491	      25.2
OCR			   3069        926	 2143	      30.2



-- tablespaces
select * from dba_data_files;
select * from DBA_TABLESPACE_USAGE_METRICS;
select USERNAME, DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE from DBA_USERS;
select TABLESPACE_NAME, round(USED_PERCENT,2) from DBA_TABLESPACE_USAGE_METRICS;
select TABLESPACE_NAME, TABLESPACE_SIZE, round(100-USED_PERCENT,0) "free percent" from DBA_TABLESPACE_USAGE_METRICS;
-- 查询tablespaces
select * from dba_tablespaces;
-- 使用以下方式添加数据文件
alter tablespace EAS_D_CKSPUB01_STANDARD add datafile '+DATADG1/zjzzdr/ckspub3.dbf' size 5G AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;
-- 如果 db_create_file_dest 有设置，例如“+DATA”的时候，使用以下方式添加数据文件
alter tablespace TICKET_TABLESPACES add datafile size 5G AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;


-- show datafile usage
col 'Tablespace Name' format a15
col 'File Name' format a50
SELECT Substr(df.tablespace_name, 1, 30) "Tablespace Name",
Round(df.maxbytes / 1024 / 1024, 2) "MaxSize (M)",
Substr(df.file_name, 1, 40) "File Name",
Round(df.bytes / 1024 / 1024, 2) "Size (M)",
Round(df.bytes / 1024 / 1024, 2) -
nvl(Round(f.free_bytes / 1024 / 1024, 2), 0) "Used (M)",
nvl(Round(f.free_bytes / 1024 / 1024, 2), 0) "Free (M)",
to_char(round((Round(df.bytes / 1024 / 1024, 2) -
            nvl(Round(f.free_bytes / 1024 / 1024, 2), 0)) /
        Round(df.bytes / 1024 / 1024, 2) * 100, 2),'990.99') || '%' use_rage, DF.AUTOEXTENSIBLE
FROM DBA_DATA_FILES DF,(SELECT Max(bytes) free_bytes, file_id FROM dba_free_space GROUP BY file_id) f
WHERE df.file_id = f.file_id(+) ORDER BY df.tablespace_name, df.file_name;


-- default tablespace determined when creating a table?
-- oracle 查看 用户，用户权限，用户表空间，用户默认表空间。
select USERNAME, DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE from DBA_USERS;


-- default datafile location
SELECT DISTINCT SUBSTR (file_name, 1, INSTR (file_name, '/', -1, 1))
FROM DBA_DATA_FILES
WHERE tablespace_name = 'SYSTEM'


-- 数据泵 impdp expdb
-- expdp cksp/NEWPASSWORD directory=expdir dumpfile=cksp83.dmp schemas=cksp exclude=TABLE:\"LIKE \'TMP%\'\"  logfile=expdp83.log parallel=2 job_name=expdpjob compression=all exclude=statistics 

expdp cks/NEWPASSWORD DUMPFILE=cd2tables.dmp DIRECTORY=data_pump_dir TABLES=CD_FACILITY,CD_PORT
exp ftsp/ftsp owner=ftsp file=20161205ftsp.dmp log=20161205ftsp.log;

create tablespace TICKET_TABLESPACES datafile '/u01/app/oracle/oradata/oltp/ticket_tablespace01.dbf' size 5G AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;
create tablespace INDEX_TABLESPACES datafile '/u01/app/oracle/oradata/oltp/index_tablespace01.dbf' size 5G AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;
alter tablespace TICKET_TABLESPACES add datafile '/u01/app/oracle/oradata/oltp/ticket_tablespace03.dbf' size 5G AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;
create user CKSP identified by NEWPASSWORD default tablespace TICKET_TABLESPACES profile default account unlock;
create user ckscjc identified by NEWPASSWORD default tablespace USERS TEMPORARY TABLESPACE temp profile default account unlock;
GRANT resource,connect,dba TO CKSP;       
impdp system/NEWPASSWORD dumpfile=cksp.dmp directory=DATA_PUMP_DIR logfile=cksp_imp.log schemas=cksp table_exists_action=replace remap_schema=cksp:cksp


-- create table
CREATE TABLE suppliers
( supplier_id number(10) NOT NULL,
  supplier_name varchar2(50) NOT NULL,
  address varchar2(50),
  city varchar2(50),
  state varchar2(25),
  zip_code varchar2(10)
);
CREATE TABLE customers
( customer_id number(10) NOT NULL,
  customer_name varchar2(50) NOT NULL,
  address varchar2(50),
  city varchar2(50),
  state varchar2(25),
  zip_code varchar2(10),
  CONSTRAINT customers_pk PRIMARY KEY (customer_id)
);
CREATE TABLE departments
( department_id number(10) NOT NULL,
  department_name varchar2(50) NOT NULL,
  CONSTRAINT departments_pk PRIMARY KEY (department_id)
);
CREATE TABLE employees
( employee_number number(10) NOT NULL,
  employee_name varchar2(50) NOT NULL,
  department_id number(10),
  salary number(6),
  CONSTRAINT employees_pk PRIMARY KEY (employee_number),
  CONSTRAINT fk_departments
    FOREIGN KEY (department_id)
    REFERENCES departments(department_id)
);


-- create tablespace

create tablespace test datafile 'test01.dbf' SIZE 20M AUTOEXTEND ON;

-- drop dataspaces
DROP TABLESPACE tbs_01 INCLUDING CONTENTS CASCADE CONSTRAINTS; 
DROP TABLESPACE tbs_02 INCLUDING CONTENTS AND DATAFILES;


-- create user
create user USERNAME identified by NEWPASSWORD default tablespace USERDEFAULTSPACE temporary tablespace USERDEFAULTSPACE profile default account unlock;
GRANT create session, create table, create sequence, create view TO test;  
GRANT UNLIMITED TABLESPACE TO TEST;


-- drop user 
-- In order to drop a user, you must have the Oracle DROP USER system privilege. The command line syntax for dropping a user can be seen below:
DROP USER edward CASCADE;

-- check procedure
SELECT * FROM ALL_OBJECTS WHERE OBJECT_TYPE IN ('FUNCTION','PROCEDURE','PACKAGE')
SELECT Text FROM User_Source;
select text from user_source where name='BATCHINPUTMEMBERINFO';
select distinct name from user_source where name like 'P_IMPORT_TICKETINFO_%'; 



-- kill session

select * from gv$lock where BLOCK!=0;
select sid,serial# from gv$session where sid=31; 
select OSUSER,MACHINE,TERMINAL,PROCESS,program from gv$session where sid = 31;
alter system kill session '31,222' immediate;

-- 杀所有来自相同machine的session
begin     
    for x in (  
            select Sid, Serial#, machine, program  
            from gv$session  
            where  
                machine = 'AP-234'  
        ) loop  
        execute immediate 'Alter System Kill Session '''|| x.Sid  
                     || ',' || x.Serial# || ''' IMMEDIATE';  
    end loop;  
end;


-- kill all other session
ALTER SYSTEM ENABLE RESTRICTED SESSION;

begin     
    for x in (  
            select Sid, Serial#, machine, program  
            from gv$session  
            where  
                machine <> 'kenneth-PC'  
        ) loop  
        execute immediate 'Alter System Kill Session '''|| x.Sid  
                     || ',' || x.Serial# || ''' IMMEDIATE';  
    end loop;  
end;

-- 

BEGIN
  FOR r IN (select sid,serial# from v$session where username='user')
  LOOP
      EXECUTE IMMEDIATE 'alter system kill session ''' || r.sid  || ',' 
        || r.serial# || ''' immediate';
  END LOOP;
END;

-- dg关库:
lsnrctl stop
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;   
 SHUTDOWN IMMEDIATE;  
 
-- grid
 sqlplus / as sysasm
 SHUTDOWN IMMEDIATE;  
  
  
  
-- dg开库
-- grid
$ sqlplus / as sysasm
select STATE,REDUNDANCY,TOTAL_MB,FREE_MB,NAME,FAILGROUP from v$asm_disk;
   
startup mount
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

$ lsnrctl start


-- adg status
select status,instance_name,database_role from v$instance,v$database;
--master:
STATUS				     INSTANCE_NAME				      DATABASE_ROLE
------------------------------------ ------------------------------------------------ ------------------------------------------------
OPEN				     zjzzdb2					      PRIMARY
--slave:
STATUS				     INSTANCE_NAME				      DATABASE_ROLE
------------------------------------ ------------------------------------------------ ------------------------------------------------
OPEN				     ZJZZDB					      PHYSICAL STANDBY




-- adg status
select process,status,thread#,sequence#,block#,blocks,delay_mins from v$managed_standby;  
--
--
--master:
PROCESS 		    STATUS				    THREAD#  SEQUENCE#	   BLOCK#     BLOCKS DELAY_MINS
--------------------------- ------------------------------------ ---------- ---------- ---------- ---------- ----------
ARCH			    CLOSING					  2	 56592	     2048	1258	      0
ARCH			    CLOSING					  2	 56593	   356352	1011	      0
ARCH			    CONNECTED					  0	     0		0	   0	      0
ARCH			    CLOSING					  2	 56594	   303104	 751	      0
ARCH			    CLOSING					  2	 56595	   311296	 440	      0
ARCH			    CLOSING					  2	 56596	   124928	1928	      0
ARCH			    CLOSING					  2	 56597	    26624	1082	      0
ARCH			    CLOSING					  2	 56598	   237568	1034	      0
ARCH			    CLOSING					  2	 56599	   210944	 916	      0
ARCH			    CLOSING					  2	 56600	   301056	1784	      0
ARCH			    CLOSING					  2	 56601	   229376	 579	      0
ARCH			    CLOSING					  2	 56602	   301056	 638	      0
ARCH			    CLOSING					  2	 56603	   303104	 666	      0
ARCH			    CLOSING					  2	 56604	   307200	  13	      0
ARCH			    CLOSING					  2	 56605	   208896	 476	      0
ARCH			    CLOSING					  2	 56606	   303104	1900	      0
ARCH			    CLOSING					  2	 56607	   198656	 930	      0
ARCH			    CLOSING					  2	 56589	   299008	1176	      0
ARCH			    CLOSING					  2	 56590	    20480	 625	      0
ARCH			    CLOSING					  2	 56591	   301056	1649	      0
LNS			    WRITING					  2	 56608	     4373	   1	      0
--
--
--slave:
PROCESS 		    STATUS				    THREAD#  SEQUENCE#	   BLOCK#     BLOCKS DELAY_MINS
--------------------------- ------------------------------------ ---------- ---------- ---------- ---------- ----------
ARCH			    CLOSING					  1	 90935	   307200	1361	      0
ARCH			    CLOSING					  1	 90936	   303104	2003	      0
ARCH			    CONNECTED					  0	     0		0	   0	      0
ARCH			    CLOSING					  2	 56607	   198656	 930	      0
RFS			    IDLE					  0	     0		0	   0	      0
RFS			    IDLE					  0	     0		0	   0	      0
RFS			    IDLE					  0	     0		0	   0	      0
RFS			    IDLE					  0	     0		0	   0	      0
RFS			    IDLE					  2	 56608	     3887	   1	      0
RFS			    IDLE					  0	     0		0	   0	      0
RFS			    IDLE					  0	     0		0	   0	      0
RFS			    IDLE					  0	     0		0	   0	      0
RFS			    IDLE					  0	     0		0	   0	      0
RFS			    IDLE					  1	 90937	    59713	2048	      0
RFS			    IDLE					  0	     0		0	   0	      0
MRP0			    APPLYING_LOG				  1	 90937	    61760     409600	      0


-- 看日志   
SELECT LOG_MODE FROM SYS.V$DATABASE;
ARCHIVE LOG LIST;
select * from v$standby_log;

	
-- 验证adg
--   主库 
select * from v$log;
alter system switch logfile;  


-- master adg ckecking
col DB_UNIQUE_NAME format a15
col PROTECTION_MODE format a25
col DATABASE_ROLE format a25
col OPEN_MODE format a25
select DB_UNIQUE_NAME,PROTECTION_MODE,database_role,open_mode from v$database;
--
--
DB_UNIQUE_NAME	PROTECTION_MODE 	  DATABASE_ROLE 	    OPEN_MODE
--------------- ------------------------- ------------------------- -------------------------
ZJZZDB		MAXIMUM PERFORMANCE	  PRIMARY		    READ WRITE


-- 两个节点都切后  

-- 看时间是否同步
select to_char(checkpoint_time,'yyyy-hh-dd hh24:mi:ss') from v$datafile;
   
   
-- 观察主，从库的归档序列号是否一致
select max(sequence#) from v$log;
--
--
--master:
MAX(SEQUENCE#)
--------------
	 90938
--
--
--slave:
MAX(SEQUENCE#)
--------------
	 90938


   
-- 查询standby库中所有已被应用的归档文件的信息 
select to_char(first_time),to_char(first_change#),to_char(next_change#),sequence# from v$log_history;
	
set linesize 200
col thread#||'_'||SEQUENCE# for a10
col name for a50
select thread#||'_'||SEQUENCE#,name,STATUS,applied,to_char(COMPLETION_TIME,'yyyy-mon-dd hh24:mi:ss') from v$archived_log order by thread#,sequence# asc;

select thread#,max(sequence#) as "last_applied_log" from v$log_history group by thread#;


-- 查询列对应的索引 indexes and columns
select * from user_ind_columns where table_name='PERSONALINFORMATION';
select * from user_indexes where table_name='PERSONALINFORMATION';
select distinct TABLE_NAME,TABLESPACE_NAME from user_indexes;


-- 查询index是否失效；
select index_name,last_analyzed,status from dba_indexes where owner='TEST';
select index_name,last_analyzed,status, NUM_ROWS from user_indexes;

alter index user1.indx rebuild;

-- index, constraints
select index_name, table_name, include_column from user_indexes;
select * from user_ind_columns;
select * from user_constraints;

-- drop CONSTRAINTS
select * from user_constraints;
alter table T1 drop CONSTRAINTS SYS_C0011666;


-- 增加索引
create index cksp.TICKETTRANSACTION_ID_IDX on cksp.PERSONALINFORMATION(TICKETTRANSACTION_ID) tablespace INDEX_TABLESPACES;
-- table from which tablespace
select table_name, tablespace_name from user_tables where table_name='RP_FREIGHT';
select owner, table_name, tablespace_name from dba_tables where OWNER='CKSP'
select name FROM V$DATAFILE;


-- directory for datadump
select DIRECTORY_NAME, DIRECTORY_PATH from dba_directories;


-- To check table statistics use:
select owner, table_name, num_rows, sample_size, last_analyzed, tablespace_name from dba_tables where owner='HR' order by owner;


-- To check table statistics use:
select index_name, table_name, num_rows, sample_size, distinct_keys, last_analyzed, status from dba_indexes where table_owner='HR' order by table_owner;


-- 收集此表的优化程序统计信息。
execute dbms_stats.gather_table_stats(ownname => 'CKSP', tabname => 'PCLINE', estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,
execute dbms_stats.gather_table_stats(ownname => 'CKSP', tabname => 'PCLINE');
execute dbms_stats.gather_schema_stats('SCOTT');

-- 接受推荐的 SQL 概要文件。
execute dbms_sqltune.accept_sql_profile(task_name => 'staName807', task_owner => 'CKSP', replace => TRUE);


-- 数据库启动时间 uptime
SELECT to_char(startup_time,'yyyy-mm-dd hh24:mi:ss') "DB Startup Time" FROM sys.v_$instance;


-- ash & awr
@?/rdbms/admin/ashrpt.sql
@?/rdbms/admin/awrrpt.sql


-- 查询是专用服务器还是 共享服务器
show parameter shared_serve
select p.program,s.server from v$session s , v$process p where s.paddr = p.addr ; 


-- check time now
SELECT TO_CHAR (SYSDATE, 'MM-DD-YYYY HH24:MI:SS') "NOW" FROM DUAL;


-- rman backup info
col OUTPUT_BYTES_DISPLAY format a20
col TIME_TAKEN_DISPLAY format a20
select start_time, status, input_type, output_bytes_display, time_taken_display from v$rman_backup_job_details order by start_time desc;


-- dba directory
SELECT * FROM SYS.DBA_DIRECTORIES;


-- get session, spid is OS process id.
COLUMN spid FORMAT A10
COLUMN username FORMAT A10
COLUMN MACHINE FORMAT A25
COLUMN program FORMAT A25
SELECT s.inst_id, s.sid, s.serial#, s.MACHINE, p.spid, s.username, s.program
FROM   gv$session s JOIN gv$process p ON p.addr = s.paddr AND p.inst_id = s.inst_id
WHERE  s.type != 'BACKGROUND';
--
--
   INST_ID	  SID	 SERIAL# SPID	    USERNAME   PROGRAM
---------- ---------- ---------- ---------- ---------- ---------------------------------------------
	 1	   44	    4599 1994	    SYS        sqlplus@kenneth (TNS V1-V3)
	 1	   50	    2249 2022	    TEST       sqlplus@kenneth (TNS V1-V3)



--  显示gv$session超过60s的查询 queries currently running for more than 60 seconds
select s.username,s.sid,s.serial#,s.last_call_et/60 mins_running from gv$session s where status='ACTIVE' and type <>'BACKGROUND' and last_call_et> 60 order by sid,serial#;


--
column USERNAME format a15
column spid format a15
select s.username, s.inst_id, s.sid, s.serial#, p.spid, s.last_call_et/60 mins_running from gv$session s, gv$process p where p.addr = s.paddr and s.status='ACTIVE' and s.type <>'BACKGROUND' and s.last_call_et> 60 order by sid,serial# ;



-- 超过20MBPGA的查询 The following query will find any sessions in an Oracle dedicated environment using over 20mb pga memory:
column PGA_ALLOC_MEM format 99,990
column PGA_USED_MEM format 99,990
column inst_id format 99
column username format a15
column program format a25
column logon_time format a25
column SPID format a15
select s.inst_id, s.sid, p.spid, s.username, s.logon_time, s.program, PGA_USED_MEM/1024/1024 PGA_USED_MEM, PGA_ALLOC_MEM/1024/1024 PGA_ALLOC_MEM from gv$session s , gv$process p Where s.paddr = p.addr and s.inst_id = p.inst_id and PGA_USED_MEM/1024/1024 > 20 order by PGA_USED_MEM;
--

INST_ID        SID SPID        USERNAME    LOGON_TIME            PROGRAM               PGA_USED_MEM PGA_ALLOC_MEM
------- ---------- --------------- --------------- ------------------------- ------------------------- ------------ -------------
      1       1701 26017950			   2018-02-11_12:45:21	     oracle@ptms3db1 (ARCE)		 45	       57
      2       1999 32309318	   CKSP 	   2018-03-02_09:21:43	     w3wp.exe				 62	       66
      1       2143 51708040	   SYSMAN	   2018-01-24_19:28:53	     OMS				 62	       64
      1       1977 43581626			   2018-01-18_01:38:50	     oracle@ptms3db1 (LMS0)		 85	       96
      1       2129 17039370			   2018-01-18_01:38:50	     oracle@ptms3db1 (LMS1)		 86	       97




--
--
column USERNAME format a10;
column 2 format a10;
column OSUSER format a10;
column SQL_ID format a10;
select S.USERNAME, s.sid, s.osuser, t.sql_id, sql_text from v$sqltext_with_newlines t,V$SESSION s
where t.address =s.sql_address and t.hash_value = s.sql_hash_value and s.status = 'ACTIVE'
and s.username <> 'SYSTEM' order by s.sid,t.piece ;
--
select S.USERNAME, s.sid, s.SERIAL#, t.sql_id, sql_text from v$sqltext_with_newlines t,V$SESSION s where t.address =s.sql_address and s.sid=114 and s.SERIAL#=2147




-- 统计信息 
-- 统计信息的收集是位于gather_stats_prog这个task，当前状态为enabled，即启用
SELECT client_name,task_name, status FROM dba_autotask_task WHERE client_name = 'auto optimizer stats collection';
SELECT program_action, number_of_arguments, enabled FROM dba_scheduler_programs WHERE owner = 'SYS' AND program_name = 'GATHER_STATS_PROG'
--统计信息收集的时间窗口
SELECT w.window_name, w.repeat_interval, w.duration, w.enabled FROM dba_autotask_window_clients c, dba_scheduler_windows w WHERE c.window_name = w.window_name AND c.optimizer_stats = 'ENABLED';
-- 自动收集统计信息历史执行情况
select * FROM dba_autotask_client_history WHERE client_name LIKE '%stats%';
-- 手动查询收集信息情况
select TABLE_NAME,NUM_ROWS,BLOCKS,LAST_ANALYZED from dba_tables where TABLE_NAME='T1';
--  执行下面的这个存储过程
EXEC DBMS_AUTO_TASK_IMMEDIATE.GATHER_OPTIMIZER_STATS;



-- 存储过程
-- create 新建一个存储过程
create or replace procedure SP_Update_Age
(
    uName in varchar,--note,here don't have length ,sql have lenth ,not in oracle.
    Age in int
)
as
begin
    update students set UserAge = UserAge + Age where userName = uName;
    commit;
end SP_Update_Age;


-- 执行一个存储过程
exec SP_UPDATE_AGE('jack',1);



-- 统计行数最多的表 the table with the most rows in the database
select TABLE_NAME, TABLESPACE_NAME, LAST_ANALYZED, NUM_ROWS from user_tables where TABLESPACE_NAME in ('TICKET_TABLESPACES', 'USERS') order by NUM_ROWS;
--
--
TABLE_NAME		       TABLESPACE_NAME		      LAST_ANALYZED	    NUM_ROWS
------------------------------ ------------------------------ ------------------- ----------
PERSONALINFORMATION	       USERS			      2018-01-29 03:09:33    6799208
PASSENGERINFO		       USERS			      2018-01-29 03:06:12    7168242
VSSDETAIL		       USERS			      2018-02-14 03:02:07    7866170
RELEASELOG		       USERS			      2017-11-18 00:19:47   10551477
TICKETPICK		       USERS			      2018-01-18 03:04:19   11429994
PASSENGERCHECKINRECORD	       USERS			      2018-01-18 03:06:49   11647350
EXCHANGETICKETDETAIL	       USERS			      2017-11-17 23:51:39   12316605
TICKETREMARK		       USERS			      2017-11-18 02:48:19   13952353
CHECKINLIST_HIST	       USERS			      2018-01-29 03:08:34   14966093
TMP_LOGONRECORD 	       TICKET_TABLESPACES	      2017-11-18 02:53:32   15092424
TICKETRECORD_CV 	       USERS			      2017-11-18 02:35:20   16416358
WEBTICKETRECORD 	       TICKET_TABLESPACES	      2018-01-07 06:06:25   16691654
FARERECORDDETAIL_HIST	       TICKET_TABLESPACES	      2017-11-18 00:00:45   22112106
GROUPTICKETDETAIL	       USERS			      2017-11-18 00:05:11   22573738
TMP_MESSAGE		       TICKET_TABLESPACES	      2018-02-11 06:05:26   25050012
TICKETSUPPLEMENT	       TICKET_TABLESPACES	      2017-11-18 02:49:26   26260661
OPERATIONLOG		       USERS			      2018-01-27 06:07:05   27760317
REPORTRECORD		       USERS			      2017-11-18 00:23:21   28932702
RESERVERECORD		       USERS			      2018-02-05 03:13:23   42263888
TICKETTRANSACTION	       TICKET_TABLESPACES	      2017-11-18 02:52:03   47389709
SWAPVOYAGELOG		       USERS			      2017-11-18 00:35:35   72325035
TICKETRECORD_ARCH	       TICKET_TABLESPACES	      2018-01-17 03:25:41  103176198
TICKETRECORD		       TICKET_TABLESPACES	      2018-01-24 06:21:31  115035999
TICKETRECORD_HIST	       USERS			      2017-11-18 02:46:58  142669418
SEATUPDATELOG		       USERS			      2017-11-18 00:32:06  174053525
VOYAGEMAPDETAIL 	       USERS			      2018-01-18 03:10:56  354257297
-- oltp PE 299个非空表 42个空表, POE 59个非空表
-- zjzz PE 335个非空表, 88 个空表


-- 启动时报错 
ERROR at line 1:  
ORA-01113: file 8 needs media recovery  
ORA-01110: data file 8: 'D:\APP\ASUS\ORADATA\WAREHOUSE\TEST03.DBF'  

RMAN> list failure;  
RMAN> advise failure;  

SQL>alter database datafile 8 offline;  
SQL>alter database recover datafile 8;  
SQL>alter database datafile 8 online;  


-- 当前错误
show errors;

select * from user_errors; 

-- 查找错误

-- 查找更新对象
col OBJECT_NAME format a30;
col OBJECT_TYPE format a15;
SELECT OBJECT_NAME , OBJECT_TYPE , TIMESTAMP, STATUS from user_objects where OBJECT_TYPE in ( 'FUNCTION', 'PACKAGE', 'PACKAGE BODY','PROCEDURE', 'SEQUENCE', 'TRIGGER', 'VIEW')  and STATUS = 'VALID' order by TIMESTAMP;


-- show sequence
select SEQUENCE_NAME,to_char(LAST_NUMBER),to_char(MAX_VALUE) from user_sequences where SEQUENCE_NAME='TICKETTRANSACTION_SEQ';


-- check session
select s.sid, s.username, s.machine, s.osuser, cpu_time, (elapsed_time/1000000)/60 as minutes, sql_text
from gv$sqlarea a, gv$session s where s.sql_id = a.sql_id and s.machine like 'AP-234' ;
--
--
       SID USERNAME   MACHINE			OSUSER	     CPU_TIME	 MINUTES
---------- ---------- ------------------------- ---------- ---------- ----------
SQL_TEXT
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	 5 CKSP       AP-234			AP-234$     281968805 205.728281
UPDATE VOYAGEMAPDETAIL SET TRANSACTION_ID = NULL WHERE TRANSACTION_ID = TO_CHAR(:B1 )

	 7 CKSP       AP-234			AP-234$     516242204 545.368544
SELECT ID,STATUS FROM VOYAGEMAPDETAIL WHERE TRANSACTION_ID = TO_CHAR(:B1 )

	10 CKSP       AP-234			AP-234$     516242204 545.368544
SELECT ID,STATUS FROM VOYAGEMAPDETAIL WHERE TRANSACTION_ID = TO_CHAR(:B1 )

	11 CKSP       AP-234			AP-234$     516242204 545.368544
SELECT ID,STATUS FROM VOYAGEMAPDETAIL WHERE TRANSACTION_ID = TO_CHAR(:B1 )


-- rman
$ rman target /


-- 列出rman备份
RMAN> list backup; 

List of Backup Sets
===================


BS Key  Type LV Size       Device Type Elapsed Time Completion Time
------- ---- -- ---------- ----------- ------------ ---------------
6       Full    1011.96M   DISK        00:00:13     27-JUN-18      
        BP Key: 6   Status: AVAILABLE  Compressed: NO  Tag: TAG20180627T162419
        Piece Name: /u01/app/oracle/flash_recovery_area/EE/backupset/2018_06_27/o1_mf_nnndf_TAG20180627T162419_fm6lfn2j_.bkp
  List of Datafiles in backup set 6
  File LV Type Ckp SCN    Ckp Time  Name
  ---- -- ---- ---------- --------- ----
  1       Full 997322     27-JUN-18 /u01/app/oracle/oradata/EE/system01.dbf
  2       Full 997322     27-JUN-18 /u01/app/oracle/oradata/EE/sysaux01.dbf
  3       Full 997322     27-JUN-18 /u01/app/oracle/oradata/EE/undotbs01.dbf
  4       Full 997322     27-JUN-18 /u01/app/oracle/oradata/EE/users01.dbf
  5       Full 997322     27-JUN-18 /u01/app/oracle/product/11.2.0/EE/dbs/test01.dbf



-- 列出 配置
RMAN> show all; 


-- 基于时间的备份保留策略 ( 3天 )
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 3 DAYS;

-- 基于备份份数保留策略 ( 3份 )
CONFIGURE RETENTION POLICY TO REDUNDANCY 3;


--  查看当前处于废弃状态的备份文件
RMAN> report obsolete;

RMAN retention policy will be applied to the command
RMAN retention policy is set to redundancy 1
Report of obsolete backups and copies
Type                 Key    Completion Time    Filename/Handle
-------------------- ------ ------------------ --------------------
Backup Set           6      27-JUN-18         
  Backup Piece       6      27-JUN-18          /u01/app/oracle/flash_recovery_area/EE/backupset/2018_06_27/o1_mf_nnndf_TAG20180627T162419_fm6lfn2j_.bkp
Backup Set           7      27-JUN-18         
  Backup Piece       7      27-JUN-18          /u01/app/oracle/flash_recovery_area/EE/backupset/2018_06_27/o1_mf_ncsnf_TAG20180627T162419_fm6lg45q_.bkp
Archive Log          5      27-JUN-18          /u01/app/oracle/flash_recovery_area/EE/archivelog/2018_06_27/o1_mf_1_9_fm6lg588_.arc
Backup Set           8      27-JUN-18         
  Backup Piece       8      27-JUN-18          /u01/app/oracle/flash_recovery_area/EE/backupset/2018_06_27/o1_mf_annnn_TAG20180627T162437_fm6lg5g0_.bkp
Archive Log          6      27-JUN-18          /u01/app/oracle/flash_recovery_area/EE/archivelog/2018_06_27/o1_mf_1_10_fm6m69cs_.arc
Backup Set           9      27-JUN-18         
  Backup Piece       9      27-JUN-18          /u01/app/oracle/flash_recovery_area/EE/backupset/2018_06_27/o1_mf_annnn_TAG20180627T163729_fm6m69l2_.bkp


-- 删除废弃备份
RMAN> delete obsolete;


-- 完全恢复

-- 目标数据库必须是mount 状态
$ rman target /
RMAN> startup mount
-- Restore是使用备份文件，将数据库还原到过去的某个状态。
RMAN> restore database;
-- Recovery是使用redo日志和归档日志将数据库向前恢复，一步步的恢复到现在这个时点。
RMAN> recover database;
RMAN> alter database open;

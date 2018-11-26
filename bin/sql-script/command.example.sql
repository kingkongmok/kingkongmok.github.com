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
select to_number(substr(value,2,2))*1440 + to_number(substr(value,5,2))*60 + to_number(substr(value,8,2)) Lag_Total from V$DATAGUARD_STATS;


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



-- 查看最近消耗最多资源的语句
-- top SQL statements that are currently stored in the SQL cache ordered by elapsed time

set linesize 180
col sql_fulltext format a25
col sql_id format a25
col FIRST_LOAD_TIME format a25
col LAST_LOAD_TIME format a25
SELECT * FROM
(SELECT sql_fulltext, sql_id, elapsed_time, child_number, disk_reads, executions, first_load_time, last_load_time
    FROM    gv$sql ORDER BY elapsed_time DESC) WHERE ROWNUM < 10 ; 

--
SQL_FULLTEXT		       SQL_ID	       ELAPSED_TIME CHILD_NUMBER DISK_READS EXECUTIONS FIRST_LOAD_TIME		 LAST_LOAD_TIME
------------------------------ --------------- ------------ ------------ ---------- ---------- ------------------------- -------------------------
BEGIN SP_ST_FEEDER_CTN_QRY(:1, 59q2zvpf2cuzz	 1637055902	       0    2060894	    27 2018-09-29/09:36:05	 2018-09-29/09:36:05
SELECT COUNT(1) FROM (SELECT S 82y10vp2p6ww3	  443434457	       0     367953	     1 2018-09-29/10:34:39	 2018-09-29/10:34:39
DECLARE job BINARY_INTEGER :=  6gvch1xu9ca3g	  342201758	       0     649290	  2576 2018-09-24/23:18:10	 2018-09-27/15:47:18


-- top 10 statements by disk read

select sql_id,child_number from
(
    select sql_id,child_number from v$sql
    order by disk_reads desc
)
where rownum<11 ;

--
-- actual plan from the SQL cache and the full text of the SQL.
SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR( &sql_id, &child ));


-- the average buffer gets per execution during a period of activity 
--
SELECT username,
buffer_gets,
disk_reads,
executions,
buffer_get_per_exec,
parse_calls,
sorts,
rows_processed,
hit_ratio,
module,
sql_text
-- elapsed_time, cpu_time, user_io_wait_time, ,
FROM (SELECT sql_text,
    b.username,
    a.disk_reads,
    a.buffer_gets,
    trunc(a.buffer_gets / a.executions) buffer_get_per_exec,
    a.parse_calls,
    a.sorts,
    a.executions,
    a.rows_processed,
    100 - ROUND (100 * a.disk_reads / a.buffer_gets, 2) hit_ratio,
    module
    -- cpu_time, elapsed_time, user_io_wait_time
    FROM v$sqlarea a, dba_users b
    WHERE a.parsing_user_id = b.user_id
    AND b.username NOT IN ('SYS', 'SYSTEM', 'RMAN','SYSMAN')
    AND a.buffer_gets > 10000
    ORDER BY buffer_get_per_exec DESC)
WHERE ROWNUM <= 20 
/

 




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
alter tablespace USERS add datafile '+DATADG1/zjzzdb/user12.dbf' size 5G AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;
alter tablespace SYSTEM add datafile '/u01/app/oracle/oradata/oltp/system02.dbf' size 5G AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;
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

expdp cksp/cksp4631 directory=DUMP_4631 dumpfile=cksp83.dmp schemas=cksp exclude=TABLE:\"LIKE \'TMP%\'\"  logfile=expdp83_1.log parallel=2 job_name=expdpjob_1 

expdp cks/NEWPASSWORD DUMPFILE=cd2tables.dmp DIRECTORY=data_pump_dir TABLES=CD_FACILITY,CD_PORT
exp ftsp/ftsp owner=ftsp file=20161205ftsp.dmp log=20161205ftsp.log;

create tablespace TICKET_TABLESPACES datafile '/u01/app/oracle/oradata/oltp/ticket_tablespace01.dbf' size 5G AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;
create tablespace INDEX_TABLESPACES datafile '/u01/app/oracle/oradata/oltp/index_tablespace01.dbf' size 5G AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;
CREATE TEMPORARY TABLESPACE TEMP_NEW TEMPFILE '/DATA/database/ifsprod/temp_01.dbf' SIZE 500m autoextend on next 10m maxsize unlimited;
alter tablespace TICKET_TABLESPACES add datafile '/u01/app/oracle/oradata/oltp/ticket_tablespace03.dbf' size 5G AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;
create user CKSP identified by NEWPASSWORD default tablespace TICKET_TABLESPACES profile default account unlock;
create user ckscjc identified by NEWPASSWORD default tablespace USERS TEMPORARY TABLESPACE temp profile default account unlock;
GRANT resource,connect,dba TO CKSP;       
impdp system/NEWPASSWORD dumpfile=cksp.dmp directory=DATA_PUMP_DIR logfile=cksp_imp.log schemas=cksp table_exists_action=replace remap_schema=cksp:cksp

--revoke dba TO CKSP;       

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

create tablespace test datafile 'test01.dbf' SIZE 40M AUTOEXTEND ON;

-- drop dataspaces
DROP TABLESPACE tbs_01 INCLUDING CONTENTS CASCADE CONSTRAINTS; 
DROP TABLESPACE tbs_02 INCLUDING CONTENTS AND DATAFILES;


-- create user/schema
CREATE USER USERNAME IDENTIFIED BY NEWPASSWORD DEFAULT TABLESPACE USERDEFAULTSPACE TEMPORARY TABLESPACE USERDEFAULTSPACE PROFILE DEFAULT ACCOUNT UNLOCK;
GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE VIEW TO TEST;  
GRANT CONNECT, RESOURCE TO USERNAME ; 
GRANT UNLIMITED TABLESPACE TO TEST;
-- CONNECT to assign privileges to the user through attaching the account to various roles
-- RESOURCE role (allowing the user to create named types for custom schemas)
-- DBA  which allows the user to not only create custom named types but alter and destroy them as well
-- ensure our new user has disk space allocated in the system to actually create or modify tables and data


-- drop user 
-- In order to drop a user, you must have the Oracle DROP USER system privilege. The command line syntax for dropping a user can be seen below:
DROP USER edward CASCADE;

-- check procedure
SELECT * FROM ALL_OBJECTS WHERE OBJECT_TYPE IN ('FUNCTION','PROCEDURE','PACKAGE')
SELECT Text FROM User_Source;
select text from user_source where name='BATCHINPUTMEMBERINFO';
select distinct name from user_source where name like 'P_IMPORT_TICKETINFO_%'; 



-- current session id, process id, client process id?
select b.sid, b.serial#, a.spid processid, b.process clientpid from v$process a, v$session b where a.addr = b.paddr and b.audsid = USERENV('SESSIONID') ;

SID SERIAL# PROCESSID CLIENTPID
———- ———- ——— ———
43 52612 420734 5852:5460

-- V$SESSION.SID and V$SESSION.SERIAL# are database process id
-- V$PROCESS.SPID – Shadow process id on the database server
-- V$SESSION.PROCESS – Client process id

-- check session and process, get PID
col MACHINE fomat a30
col PROGRAM fomat a25
col CLIENTPID fomat a25
select distinct s.sid, s.serial#, s.machine, s.program,  s.process clientpid from gv$session s where s.sid=&sid ; 

       SID    SERIAL# MACHINE			PROGRAM 		  CLIENTPID
---------- ---------- ------------------------- ------------------------- -------------------------
       630	53521 WORKGROUP\PTMSB2B-212	w3wp.exe		  2080:3652


-- kill session

select * from gv$lock where BLOCK!=0;
select sid,serial# from gv$session where sid=&sid; 
alter system kill session '&sid,&serial' immediate;

select OSUSER,MACHINE,TERMINAL,PROCESS,program from gv$session where sid = &sid;

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

-- 成华提供

-- 1、检查主备两边的序号
select max(sequence#) from v$log;   ---检查发现一致

-- 2、备库执行，查看是否有数据未应用
select name,SEQUENCE#,APPLIED from v$archived_log order by sequence#;

select SEQUENCE#,FIRST_TIME,NEXT_TIME ,APPLIED from v$archived_log order by 1;


-- 3、检查备库是否开启实时应用
select recovery_mode from v$archive_dest_status where dest_id=2;


-- 4、检查备库状态
select switchover_status from v$database; --发现状态not allowed 



-- 查询列对应的索引 indexes and columns
select * from user_ind_columns where table_name='PERSONALINFORMATION';
select * from user_indexes where table_name='PERSONALINFORMATION';
select distinct TABLE_NAME,TABLESPACE_NAME from user_indexes;


-- 查询index是否失效；
select index_name,last_analyzed,status from dba_indexes where owner='CKSP';
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
-- single table
exec DBMS_STATS.GATHER_TABLE_STATS (ownname => 'SMART' , tabname => 'AGENT',cascade => true, estimate_percent => 10,method_opt=>'for all indexed columns size 1', granularity => 'ALL', degree => 1);
-- index
exec dbms_stats.gather_index_stats(null, 'IDX_PCTREE_PARENTID', null, DBMS_STATS.AUTO_SAMPLE_SIZE);
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
select s.username, s.inst_id, s.sid, s.serial#, s.program, s.machine, p.spid, s.last_call_et/60 mins_running from gv$session s, gv$process p where p.addr = s.paddr and s.status='ACTIVE' and s.type <>'BACKGROUND' and s.last_call_et> 60 order by sid,serial# ;


-- 查看在跑什么
-- https://community.oracle.com/thread/2354739?start=0&tstart=0
select a.sid, a.username,b.sql_id, b.sql_fulltext from gv$session a, gv$sql b where a.sql_id = b.sql_id and a.status = 'ACTIVE' and a.username != 'SYS';


--  SQL ordered by Elapsed Time in 20mins, like awr
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
    round(CPU_TIME/1000000/EXECUTIONS,2) CPU_PER_SEC,
    round(user_io_wait_time/1000000,2) TOTAL_USER_IO,
    round(user_io_wait_time/1000000/EXECUTIONS,2) USER_IO_PER_EXEC,  
    to_char(LAST_ACTIVE_TIME , 'hh24:mm:ss') LAST_ACTIVE_TIME,
    module
    from v$sqlarea a where
    LAST_ACTIVE_TIME >=  (sysdate - 20/60*24)
    and sql_fulltext like '%TICKETRECORD_HIST%'
    order by ELAPSED_PER_EXEC desc)
where ROWNUM < 6
/


SQL_ID         EXES   TOTAL_ELAPSED ELAPSED_PER_EXE       TOTAL_CPU     CPU_PER_SEC   TOTAL_USER_IO USER_IO_PER_EXE LAST_ACT MODULE             
------------- ----- --------------- --------------- --------------- --------------- --------------- --------------- -------- --------------------
4z1xp5zx99mr7     2         18730.2          9365.1           96.45           48.22        16529.86         8264.93 14:11:11 DataExchange.exe    
98sz9txr8z1m4     7        24956.02         3565.15          381.22           54.46        24567.53         3509.65 14:11:56 DataExchange.exe    
9j5grcp042mhs     2         1861.95          930.98           20.36           10.18         1844.59          922.29 14:11:28 DataExchange.exe    
64gtpnfwx4uqn     1             .09             .09             .06             .06             .02             .02 11:11:29 SQL Developer       
7hmyj1rctb0bx     2             .18             .09             .11             .06             .05             .02 14:11:04 SQL Developer       




-- 超过20MBPGA的查询 The following query will find any sessions in an Oracle dedicated environment using over 20mb pga memory:
column pgA_ALLOC_MEM format 99,990
column PGA_USED_MEM format 99,990
column inst_id format 99
column username format a15
column program format a25
column logon_time format a25
column SPID format a15
select s.inst_id, s.sid, s.serial#, p.spid, s.username, s.logon_time, s.program, PGA_USED_MEM/1024/1024 PGA_USED_MEM, PGA_ALLOC_MEM/1024/1024 PGA_ALLOC_MEM from gv$session s , gv$process p Where s.paddr = p.addr and s.inst_id = p.inst_id and PGA_USED_MEM/1024/1024 > 20 order by PGA_USED_MEM;
--

INST_ID        SID    SERIAL# SPID	      USERNAME	      LOGON_TIME		PROGRAM 		  PGA_USED_MEM PGA_ALLOC_MEM
------- ---------- ---------- --------------- --------------- ------------------------- ------------------------- ------------ -------------
      2       4474	    1 12275			      2018-10-12_12:02:58	oracle@ckstmis-db2 (ARCH)	    41		  44
      1       3480	    1 10846			      2018-10-12_12:14:28	oracle@ckstmis-db1 (ARC3)	    51		  55
      2       3764	    5 12255			      2018-10-12_12:02:57	oracle@ckstmis-db2 (ARC7)	    51		  55
      2       3551	   15 12249			      2018-10-12_12:02:57	oracle@ckstmis-db2 (ARC4)	    51		  55
      2       3409	   37 12245			      2018-10-12_12:02:57	oracle@ckstmis-db2 (ARC2)	    51		  55
      1       3764	    1 10855			      2018-10-12_12:14:28	oracle@ckstmis-db1 (ARC7)	    52		  56
      1       1990	22249 26260	      CKS	      2018-10-19_10:19:34	JDBC Thin Client		    83		  92
      1       3559	60977 54081	      CKS	      2018-10-19_11:00:45	JDBC Thin Client		   209		 218



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
select S.USERNAME, s.sid, s.SERIAL#, t.sql_id, sql_text from v$sqltext_with_newlines t,V$SESSION s where t.address =s.sql_address and s.sid=&sid and s.SERIAL#=&serial;




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
SELECT OBJECT_NAME , OBJECT_TYPE , TIMESTAMP, STATUS from user_objects where OBJECT_TYPE in ( 'FUNCTION', 'PACKAGE', 'PACKAGE BODY','PROCEDURE', 'SEQUENCE', 'TRIGGER', 'VIEW')  and STATUS = 'VALID' order by TIMESTAMP desc;


-- show sequence
select SEQUENCE_NAME,to_char(LAST_NUMBER),to_char(MAX_VALUE) from user_sequences where SEQUENCE_NAME='TICKETTRANSACTION_SEQ';


-- check session
select s.sid, s.username, s.machine, s.osuser, cpu_time, (elapsed_time/1000000)/60 as minutes, sql_text from gv$sqlarea a, gv$session s where s.sql_id = a.sql_id and s.sid = '&sid' ;
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

-- 异常和建议
RMAN> list failure;  
RMAN> advise failure;  

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


-- delete obsolete 

RMAN> CONFIGURE RETENTION POLICY TO REDUNDANCY 2;

old RMAN configuration parameters:
CONFIGURE RETENTION POLICY TO REDUNDANCY 2;
new RMAN configuration parameters:
CONFIGURE RETENTION POLICY TO REDUNDANCY 2;
new RMAN configuration parameters are successfully stored

RMAN> delete obsolete ; 

RMAN retention policy will be applied to the command
RMAN retention policy is set to redundancy 2
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=71 device type=DISK
Deleting the following obsolete backups and copies:
Type                 Key    Completion Time    Filename/Handle
-------------------- ------ ------------------ --------------------
Archive Log          248    05-JUL-18          /u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_05/o1_mf_1_1_fmvr3bjx_.arc
Archive Log          249    05-JUL-18          /u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_05/o1_mf_1_2_fmvr3dk2_.arc
Archive Log          250    05-JUL-18          /u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_05/o1_mf_1_3_fmvr3gfz_.arc
Archive Log          251    05-JUL-18          /u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_05/o1_mf_1_4_fmvr3s6b_.arc
Archive Log          252    06-JUL-18          /u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_06/o1_mf_1_5_fmwmh5gr_.arc
Archive Log          253    06-JUL-18          /u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_06/o1_mf_1_6_fmxgd05w_.arc
Archive Log          254    06-JUL-18          /u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_06/o1_mf_1_7_fmxgd70l_.arc
Backup Set           79     06-JUL-18         
  Backup Piece       79     06-JUL-18          /u01/app/oracle/flash_recovery_area/EE/backupset/2018_07_06/o1_mf_nnndf_TAG20180706T083948_fmxglo4w_.bkp
Backup Set           80     06-JUL-18         
  Backup Piece       80     06-JUL-18          /u01/app/oracle/product/11.2.0/EE/dbs/c-1893248064-20180706-00

Do you really want to delete the above objects (enter YES or NO)? yes
deleted archived log
archived log file name=/u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_05/o1_mf_1_1_fmvr3bjx_.arc RECID=248 STAMP=980701802
deleted archived log
archived log file name=/u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_05/o1_mf_1_2_fmvr3dk2_.arc RECID=249 STAMP=980701804
deleted archived log
archived log file name=/u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_05/o1_mf_1_3_fmvr3gfz_.arc RECID=250 STAMP=980701806
deleted archived log
archived log file name=/u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_05/o1_mf_1_4_fmvr3s6b_.arc RECID=251 STAMP=980701817
deleted archived log
archived log file name=/u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_06/o1_mf_1_5_fmwmh5gr_.arc RECID=252 STAMP=980729829
deleted archived log
archived log file name=/u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_06/o1_mf_1_6_fmxgd05w_.arc RECID=253 STAMP=980757376
deleted archived log
archived log file name=/u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_06/o1_mf_1_7_fmxgd70l_.arc RECID=254 STAMP=980757383
deleted backup piece
backup piece handle=/u01/app/oracle/flash_recovery_area/EE/backupset/2018_07_06/o1_mf_nnndf_TAG20180706T083948_fmxglo4w_.bkp RECID=79 STAMP=980757589
deleted backup piece
backup piece handle=/u01/app/oracle/product/11.2.0/EE/dbs/c-1893248064-20180706-00 RECID=80 STAMP=980757644
Deleted 9 objects


-- delete expired

RMAN> crosscheck archivelog all ;

released channel: ORA_DISK_1
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=71 device type=DISK
validation succeeded for archived log
archived log file name=/u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_06/o1_mf_1_8_fmxkgsdd_.arc RECID=255 STAMP=980760537
validation succeeded for archived log
archived log file name=/u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_06/o1_mf_1_9_fmxkgtn2_.arc RECID=256 STAMP=980760538
validation succeeded for archived log
archived log file name=/u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_06/o1_mf_1_10_fmxkgwwn_.arc RECID=257 STAMP=980760540
validation succeeded for archived log
archived log file name=/u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_06/o1_mf_1_11_fmxl00kb_.arc RECID=258 STAMP=980761088
validation succeeded for archived log
archived log file name=/u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_06/o1_mf_1_12_fmxl0qdz_.arc RECID=259 STAMP=980761111
Crosschecked 5 objects


RMAN> host;

[oracle@dfcc11b5e819 ~]$ rm -f /u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_06/o1_mf_1_8_fmxkgsdd_.arc
[oracle@dfcc11b5e819 ~]$ exit
host command complete

RMAN> crosscheck archivelog all ;

released channel: ORA_DISK_1
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=71 device type=DISK
validation failed for archived log
archived log file name=/u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_06/o1_mf_1_8_fmxkgsdd_.arc RECID=255 STAMP=980760537
validation succeeded for archived log
archived log file name=/u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_06/o1_mf_1_9_fmxkgtn2_.arc RECID=256 STAMP=980760538
validation succeeded for archived log
archived log file name=/u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_06/o1_mf_1_10_fmxkgwwn_.arc RECID=257 STAMP=980760540
validation succeeded for archived log
archived log file name=/u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_06/o1_mf_1_11_fmxl00kb_.arc RECID=258 STAMP=980761088
validation succeeded for archived log
archived log file name=/u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_06/o1_mf_1_12_fmxl0qdz_.arc RECID=259 STAMP=980761111
Crosschecked 5 objects


RMAN> delete expired archivelog all ; 

released channel: ORA_DISK_1
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=71 device type=DISK
List of Archived Log Copies for database with db_unique_name EE
=====================================================================

Key     Thrd Seq     S Low Time 
------- ---- ------- - ---------
255     1    8       X 06-JUL-18
        Name: /u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_06/o1_mf_1_8_fmxkgsdd_.arc


Do you really want to delete the above objects (enter YES or NO)? yes
deleted archived log
archived log file name=/u01/app/oracle/flash_recovery_area/EE/archivelog/2018_07_06/o1_mf_1_8_fmxkgsdd_.arc RECID=255 STAMP=980760537
Deleted 1 EXPIRED objects


-- create dblink
-- https://dba.stackexchange.com/questions/54185/create-database-link-on-oracle-database-with-2-databases-on-different-machines
--list dblik
SELECT * FROM ALL_DB_LINKS;
-- You can define the connection string via tnsnames.ora ( $ORACLE_HOME/network/admin/tnsnames.ora ) then reference the alias
remotedb =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = remotedb.fqdn.com)(PORT = 1521))
    (CONNECT_DATA = (SERVICE_NAME = ORCL))
  )
-- Then create a dblink referencing that alias:
drop database link remotedb;
CREATE DATABASE LINK remotedb
    CONNECT TO SYSTEM IDENTIFIED BY <password>
    USING 'remotedb';
-- Or facilitate the same inline with:
CREATE DATABASE LINK remotedb
CONNECT TO SYSTEM IDENTIFIED BY <password>
USING'(DESCRIPTION =(ADDRESS = (PROTOCOL = TCP)(HOST = remotedb.fqdn.com)(PORT = 1521))(CONNECT_DATA = (SERVICE_NAME = ORCL)))';


-- 查看是否有权限进程dblink操作
select * from user_sys_privs where privilege like upper('%DATABASE LINK%');  




-- XX数据迁移方案 - 副本

-- 方案一  冷库直接拷贝

-- 1首先删除以前的归档（可保留七天）

-- a、rman模式删除
--rman target用户名/密码@实例名
rman >DELETE ARCHIVELOG UNTIL TIME 'SYSDATE-7';删除7前的所有归档日志。
rman >crosscheck archivelog all;
rman >delete noprompt expired archivelog all;
rman>crosscheck archivelog all;
rman> delete expired archivelog all;

 -- 或

rman target /
RMAN> crosscheck archivelog all; --验证的DB的归档日志
RMAN> delete expired archivelog all; --删除所有失效归档日志
RMAN> DELETE ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-7';--保留7天的归档日志
RMAN>DELETE ARCHIVELOG ALL; --完全删除归档


-- b、使用操作系统命令删除
su - oracle
cd /oradata/arch
find . -xdev -mtime +7 -name "*.dbf" -exec rm -f {} \;
然后rman target /
RMAN> crosscheck archivelog all; --验证的DB的归档日志
RMAN> delete expired archivelog all; --删除所有失效归档日志

-- 关闭归档命令如下：
-- 关闭归档
SQL> alter system set log_archive_start=false scope=spfile; --禁用自归档 oracle10g以后 这条命令就不需要了。。
SQL> shutdown immediate; --强制关闭数据库
SQL> startup mount; --重启数据库到mount模式
SQL> alter database noarchivelog; --修改为非归档模式
SQL> alter database open; --打数据文件
SQL> archive log list; --再次查看前归档模式

-- 2、数据复制
find /u01 -type s
cp -R -p  /u01  /u01_2
cp -R -p /oradata /oradata_2    

-- 3、文件系统重新挂载

umount /u01
umount /oradata
umount /u01_2
umount /oradata_2

--需要修改文件系统挂载参数，即把原来的两个文件系统的自动挂载改为手动挂载，把新建的两个文件系统的自动挂载点改为/u01和/oradata
--（需做实验）

-- 然后挂载：
mount /u01
mount /oradata




--  方案二  RMAN备份恢复
-- Rman备份再恢复

-- 1、数据库做全备
Shutdown immediate;
Startup mount;
Alter database open read only;   -- 这几步可以省略

rman target /

-- 并记录下dbid： --完全恢复可以不需要

-- 检查database错误（物理和逻辑）
backup validate check logical database;    --这一步最好事先检查一下

backup as compressed backupset full database include current controlfile plus archivelog;


-- 备份脚本如下：

RMAN> 
run{
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
allocate channel ch3 device type disk;
allocate channel ch4 device type disk;
crosscheck archivelog all;
delete expired archivelog all;  --若手工没删除控制文件，这两行可以取消
backup as compressed backupset format '/expdp/FULL_%U' database include current controlfile;
sql 'alter system archive log current';  --这一步其实完全不需要，全备会执行三次
backup archivelog all format '/expdp/ARC_%U';
release channel ch1 ;
release channel ch2 ;
release channel ch3 ;
release channel ch4 ;
}

--备注：设置控制文件的自动备份路径命令为：
set controlfile autobackup format for device type disk to ‘/u01/xxx/%F’;
-- 这样恢复时可以直接：
Restore controlfile autobackup;

sqlplus / as sysdba
create pfile from spfile;

RMAN> report schema; --可以查看原数据文件信息，并登记


-- 2、备份文件拷贝

-- 把pfile(inithzxzdb.ora)、redolog、rman备份集文件夹 拷贝到其他的目录：

cp -R -p /u01/app/oracle/fast_recovery_area/HZXZDB/ /home
cp -p /oradata/hzxzdb/redo* /home
cp -p /oradata/hzxzdb/control* /home
cp -R -p $ORACLE_HOME/dbs/ /home
cp -p /u01/app/oracle/product/11.2.0/db_1/network/admin/listener.ora /home
cp -p /u01/app/oracle/product/11.2.0/db_1/network/admin/tnsnames.ora /home



-- 3、删除lv、vg、pv，卸载磁盘（不知道需不需要先dbca把库给干掉） 其实可以简单的 直接umount /u01 ;  umount /oradata，然后修改文件系统挂载点，从自动挂载改为手动挂载。
--
-- 4、新的磁盘挂载，建3.2章节
--
-- 5、安装oracle数据库软件，安装监听等；
--
-- 6、创建目录，并把备份的数据拷贝过去

mkdir -p /u01/app/oracle/admin/hzxzdb/adump
chown -R oracle:dba /u01/app/oracle/admin/

cd /u01/app/oracle/fast_recovery_area/
mkdir hzxzdb
chmod -R 750 /u01/app/oracle/fast_recovery_area/
chown -R oracle:oinstall /u01/app/oracle/fast_recovery_area/
cp -R -p /home/HZXZDB /u01/app/oracle/fast_recovery_area/


cd /oradata/hzxzdb
cp -p /home/redo* /oradata/hzxzdb
cp -p /home/inithzxzdb.ora /u01/app/oracle/product/11.2.0/dbhome_1/dbs

-- 7、rman恢复

sqlplus / as sysdba
startup nomount pfile='/u01/app/oracle/product/11.2.0/dbhome_1/dbs/inithzxzdb.ora';

rman target /
RMAN> set dbid xxxx;
RMAN> restore spfile from autobackup;  --目录相同的话可以直接拷贝，若目录不同的话需要由修改后的pfile生成spfile；
restore controlfile from autobackup;
shutdown immediate;
startup mount;


--注册备份集信息，把最新的备份集信息（即路径）注册到控制文件中，这样restore database时可以自动发现备份集。若备份集路径和原始的路径一致，则不需要注册备份集：
catalog start with '/expdp/'

-- 恢复数据文件（数据文件路径一致）
run{
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
allocate channel ch3 device type disk;
allocate channel ch4 device type disk;
restore database;
release channel ch1;
release channel ch2;
release channel ch3;
release channel ch4;
}

recover database;  --上面的这个方式下，根本不需要recover，即不需要redolog；
alter database open resetlogs;  

-- 注：AIX系统oracle数据库自动启动：
-- 1、vi /etc/oratab  并添加：
ORACLE_SID:ORACLE_HOME:Y
-- 2、vi $ORACLE_HOME/bin/dbstart
-- 对ORACLE_HOME_LISTENER一行进行修改，使其等于$ORACLE_HOME
-- 3、编写数据库启动脚本  vi /etc/rc.startdb
-- 添加：
su - oracle “-c /u01/app/oracle/product/11.2.0/db_1/bin/dbstart”
-- 4、为此文件授予可执行的权限：chmod +x /etc/rc.startdb
-- 5、vi /etc/inittab
-- 添加：
startdb:2:once:/etc/rc.startdb
-- 或者使用mkitab命令将启动条目添加到/etc/initab文件中
#mkitab “startdb:2:once:/etc/rc.startdb > /dev/null 2>&1”


-- 2.4.3 方案三  数据泵导入导出
-- 1、导出
-- A、创建directory域，分配dump文件目录
-- 然后给需要导出的模式（用户）分配读写权限给directory域。
SQL> create directory dump_file_dir as '/u01test';
Directory created.
SQL> grant read,write on directory dump_file_dir to gabsj, hztb, xttb,mylcpt;
Grant succeeded.
-- B、以每一个用户去执行全库导出
-- （导出整个数据）
expdp sys/oracle@10.118.137.9/hzxzdb as sysdba directory=dump_file_dir full=y dumpfile=allfile.dmp logfile=allfile.log 

-- 针对用户去导出：
expdp gabsj/xxx@10.118.137.9/hzxzdb directory=dump_file_dir full=y dumpfile= gabsj _file.dmp logfile=gabsj _file.log 

expdp hztb/xxx@10.118.137.9/hzxzdb directory=dump_file_dir full=y dumpfile= hztb _file.dmp logfile=hztb _file.log 

expdp xttb/xxx@10.118.137.9/hzxzdb directory=dump_file_dir full=y dumpfile= xttb _file.dmp logfile=xttb _file.log 

expdp mylcpt /xxx@10.118.137.9/hzxzdb directory=dump_file_dir full=y dumpfile= mylcpt _file.dmp logfile=mylcpt _file.log 


-- 2、原数据库删除，数据库软件删除
--
-- 3、安装oracle软件，并新建数据库
--
-- 4、导入
--
-- 第一步：新建所有模式（用户）
-- 并建表空间，给用户赋予表空间
-- 需要知道这四个用户的密码：gabsj,hztb,xttb,mylcpt
create user GABSJ
identified by values ''
default tablespace TS_MYLCPT
temporary tablespace TS_TEMP_MYLCPT;

grant RESOURCE to GABSJ;
grant CONNECT to GABSJ;


create user HZTB
identified by values ''
default tablespace TS_MYLCPT
temporary tablespace TS_TEMP_MYLCPT;

grant CONNECT to HZTB;
grant RESOURCE to HZTB;

create user XTTB
identified by values ''
default tablespace TS_MYLCPT
temporary tablespace TS_TEMP_MYLCPT;

grant CONNECT to XTTB;
grant RESOURCE to XTTB;

create user MYLCPT
identified by values ''
default tablespace TS_MYLCPT
temporary tablespace TS_TEMP_MYLCPT;

grant RESOURCE to MYLCPT;
grant CONNECT to MYLCPT;

-- 依照上面的模板去创建用户和表空间，命令如下：
create tablespace ts_mylcpt datafile '/oradata/oradata/hzxzdb/ts_mylcpt01.dbf' size 30G autoextend off; 
alter tablespace ts_mylcpt add datafile '/oradata/oradata/hzxzdb/ts_mylcpt02.dbf' size 30G autoextend off;
alter tablespace ts_mylcpt add datafile '/oradata/oradata/hzxzdb/ts_mylcpt03.dbf' size 30G autoextend off;
alter tablespace ts_mylcpt add datafile '/oradata/oradata/hzxzdb/ts_mylcpt04.dbf' size 30G autoextend off;
create temporary tablespace ts_temp_mylcpt tempfile '/oradata/oradata/hzxzdb/ts_temp_mylcpt01.dbf' size 30G autoextend off;
alter tablespace ts_temp_mylcpt add tempfile  '/oradata/oradata/hzxzdb/ts_temp_mylcpt02.dbf' size 30G autoextend off;
create  tablespace ts_idx_mylcpt datafile '/oradata/oradata/hzxzdb/ts_idx_mylcpt01.dbf' size 30G autoextend off; 
alter tablespace ts_idx_mylcpt add datafile '/oradata/oradata/hzxzdb/ts_idx_mylcpt02.dbf' size 30G autoextend off;

-- 创建用户：
create user MYLCPT identified by hzxzzd321 
default tablespace ts_mylcpt
temporary tablespace ts_temp_mylcpt
profile default
account unlock;
grant connect,resource to MYLCPT;

create user GABSJ identified by XXXX
default tablespace TS_MYLCPT
temporary tablespace TS_TEMP_MYLCPT
profile default
account unlock;
grant connect,resource to GABSJ;

create user XTTB identified by XXXX
default tablespace TS_MYLCPT
temporary tablespace TS_TEMP_MYLCPT
profile default
account unlock;
grant connect,resource to XTTB;

create user HZTB identified by XXXX
default tablespace TS_MYLCPT
temporary tablespace TS_TEMP_MYLCPT
profile default
account unlock;
grant connect,resource to HZTB;

-- 第二步：创建directory域，分配dump文件目录
-- 然后给需要导出的模式（用户）分配读写权限给directory域。
SQL> create directory dump_file_dir as '/u01test';
Directory created.
SQL> grant read,write on directory dump_file_dir to gabsj,hztb,xttb,mylcpt;
Grant succeeded.


-- 第三步：把dmp文件拷贝至此机
-- 然后导入：以不同的用户进行全部导入
impdp gabsj/gabsj directory=dump_file_dir dumpfile=allfile.dmp nologfile=y content=all
impdp hztb/hztb directory=dump_file_dir dumpfile=allfile.dmp nologfile=y content=all
impdp xttb/xttb directory=dump_file_dir dumpfile=allfile.dmp nologfile=y content=all
impdp mylcpt/mylcpt directory=dump_file_dir dumpfile=allfile.dmp nologfile=y content=all

-- crs 命令

$ source  profile_grid


-- 启动 crs
/oracle/11.2.0/grid/gridhome/bin/crsctl start cluster

-- 查看当前的服务器启动情况，
$ crs_stat -t
Name           Type           Target    State     Host        
------------------------------------------------------------
ora.DATA.dg    ora....up.type ONLINE    ONLINE    orcl        
ora.INIT.dg    ora....up.type ONLINE    ONLINE    orcl        
ora....ER.lsnr ora....er.type OFFLINE   OFFLINE               
ora.asm        ora.asm.type   ONLINE    ONLINE    orcl        
ora.cssd       ora.cssd.type  ONLINE    ONLINE    orcl        
ora.diskmon    ora....on.type OFFLINE   OFFLINE               
ora.evmd       ora.evm.type   ONLINE    ONLINE    orcl        
ora.ons        ora.ons.type   OFFLINE   OFFLINE               
ora.orcl.db    ora....se.type OFFLINE   OFFLINE              

-- 删除旧服务
$ srvctl remove database -d orcl
Remove the database orcl? (y/[n]) y

-- 添加服务
$ srvctl add database -d ee -o /u01/app/oracle/product/11.2.0/dbhome_1 


-- 检查是否重启生效

-- https://oracleracdba1.wordpress.com/2013/01/29/how-to-set-auto-start-resources-in-11g-rac/
$ crsctl stat res -p | perl -00 -ne  ' print if /ora.database.type/' | grep AUTO_START
AUTO_START=restore

-- 设置重启
crsctl modify resource "ora.ee.db" -attr "AUTO_START=always"

$ crsctl stat res -p | perl -00 -ne  ' print if /ora.database.type/' | grep AUTO_START
AUTO_START=always

-- 查看情况
$ crs_stat -t
Name           Type           Target    State     Host        
------------------------------------------------------------
ora.DATA.dg    ora....up.type ONLINE    ONLINE    orcl        
ora.INIT.dg    ora....up.type ONLINE    ONLINE    orcl        
ora....ER.lsnr ora....er.type ONLINE    OFFLINE               
ora.asm        ora.asm.type   ONLINE    ONLINE    orcl        
ora.cssd       ora.cssd.type  ONLINE    ONLINE    orcl        
ora.diskmon    ora....on.type OFFLINE   OFFLINE               
ora.ee.db      ora....se.type OFFLINE   OFFLINE               
ora.evmd       ora.evm.type   ONLINE    ONLINE    orcl        
ora.ons        ora.ons.type   OFFLINE   OFFLINE        

-- 启动
$ crs_start ora.ee.db
Attempting to start `ora.ee.db` on member `orcl`
Start of `ora.ee.db` on member `orcl` succeeded.

--检查
$ crs_stat -t
Name           Type           Target    State     Host        
------------------------------------------------------------
ora.DATA.dg    ora....up.type ONLINE    ONLINE    orcl        
ora.INIT.dg    ora....up.type ONLINE    ONLINE    orcl        
ora....ER.lsnr ora....er.type ONLINE    ONLINE    orcl        
ora.asm        ora.asm.type   ONLINE    ONLINE    orcl        
ora.cssd       ora.cssd.type  ONLINE    ONLINE    orcl        
ora.diskmon    ora....on.type OFFLINE   OFFLINE               
ora.ee.db      ora....se.type ONLINE    ONLINE    orcl        
ora.evmd       ora.evm.type   ONLINE    ONLINE    orcl        
ora.ons        ora.ons.type   OFFLINE   OFFLINE      

-- 关闭所有服务
$ crs_stop -all



-- asm drop
ASMCMD> rm -rf DATA

ASMCMD> dropdg -r data

ASMCMD> dropdg -r init
ORA-15039: diskgroup not dropped
ORA-15027: active use of diskgroup "INIT" precludes its dismount (DBD ERROR: OCIStmtExecute)

ASMCMD> dropdg -r init
ORA-15039: diskgroup not dropped
ORA-15027: active use of diskgroup "INIT" precludes its dismount (DBD ERROR: OCIStmtExecute)

ASMCMD> lsdg
State    Type    Rebal  Sector  Block       AU  Total_MB  Free_MB  Req_mir_free_MB  Usable_file_MB  Offline_disks  Voting_files  Name
MOUNTED  EXTERN  N         512   4096  1048576      1019      960                0             960              0             N  INIT/

-- 无法删除INIT ,

SQL> SELECT name, header_status, path FROM V$ASM_DISK; 

NAME			       HEADER_STATUS	    PATH
------------------------------ -------------------- -------------------------
			       FORMER		    ORCL:ASMDISK2
			       FORMER		    ORCL:ASMDISK3
			       FORMER		    ORCL:ASMDISK4
ASMDISK1		       MEMBER		    ORCL:ASMDISK1


SQL>  create pfile=’/tmp/init.ora‘  from spfile;

SQL> 
SQL> shutdown immediate; 
ASM diskgroups dismounted
ASM instance shutdown
SQL> startup pfile='/tmp/init.ora' ; 
ASM instance started

Total System Global Area 1135747072 bytes
Fixed Size		    2260728 bytes
Variable Size		 1108320520 bytes
ASM Cache		   25165824 bytes
ORA-15110: no diskgroups mounted


SQL> SELECT name, header_status, path FROM V$ASM_DISK; 

NAME			       HEADER_STATUS	    PATH
------------------------------ -------------------- -------------------------
			       MEMBER		    ORCL:ASMDISK1
			       FORMER		    ORCL:ASMDISK4
			       FORMER		    ORCL:ASMDISK3
			       FORMER		    ORCL:ASMDISK2

SQL> DROP DISKGROUP INIT FORCE INCLUDING CONTENTS;

Diskgroup dropped.


-- create asm diskgroup
-- https://www.hhutzler.de/blog/using-asm-spfile/

SQL> col PATH format a40
SQL> select path,header_status from v$asm_disk;

PATH					 HEADER_STATU
---------------------------------------- ------------
ORCL:ASMDISK1				 FORMER
ORCL:ASMDISK4				 FORMER
ORCL:ASMDISK3				 FORMER
ORCL:ASMDISK2				 FORMER

SQL> CREATE DISKGROUP FRA EXTERNAL REDUNDANCY DISK 'ORCL:ASMDISK1' ; 

Diskgroup created.

SQL> CREATE DISKGROUP OCR EXTERNAL REDUNDANCY DISK 'ORCL:ASMDISK2' ; 

Diskgroup created.

SQL> CREATE DISKGROUP DATA EXTERNAL REDUNDANCY DISK 'ORCL:ASMDISK3', 'ORCL:ASMDISK4' ; 

Diskgroup created.

SQL> select path,header_status from v$asm_disk;

PATH					 HEADER_STATU
---------------------------------------- ------------
ORCL:ASMDISK1				 MEMBER
ORCL:ASMDISK2				 MEMBER
ORCL:ASMDISK3				 MEMBER
ORCL:ASMDISK4				 MEMBER

SQL> Disconnected from Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Automatic Storage Management option
oracle@orcl ~ $ asmcmd -p
ASMCMD [+] > ls
DATA/
FRA/
OCR/
ASMCMD [+] > exit

-- 更换数据文件到asm
-- https://www.thegeekdiary.com/how-to-move-a-datafile-from-filesystem-to-asm-using-asmcmd-cp-command/

col FILE_NAME format a50
select file_name, file_id from dba_data_files;


FILE_NAME					      FILE_ID
-------------------------------------------------- ----------
/u01/app/oracle/oradata/EE/users01.dbf			    4
/u01/app/oracle/oradata/EE/undotbs01.dbf		    3
/u01/app/oracle/oradata/EE/sysaux01.dbf 		    2
/u01/app/oracle/oradata/EE/system01.dbf 		    1
/u01/app/oracle/oradata/EE/test_tablespace01.dbf	    5

alter database datafile 5 offline;
Database altered.


select file_name, file_id, online_status from dba_data_files where file_id=5;

FILE_NAME					      FILE_ID ONLINE_
-------------------------------------------------- ---------- -------
/u01/app/oracle/oradata/EE/test_tablespace01.dbf	    5 RECOVER


ASMCMD> mkdir EE/
ASMCMD> mkdir EE/DATAFILE
ASMCMD> cd /
ASMCMD> cp /u01/app/oracle/oradata/EE/test_tablespace01.dbf +DATA/EE/DATAFILE/test_tablespace01.dbf
copying /u01/app/oracle/oradata/EE/test_tablespace01.dbf -> +DATA/EE/DATAFILE/test_tablespace01.dbf
ASMCMD> ls -lt +DATA/EE/DATAFILE/
Type      Redund  Striped  Time             Sys  Name
                                            N    test_tablespace01.dbf => +DATA/ASM/DATAFILE/test_tablespace01.dbf.256.982344385


SQL> alter database rename file '/u01/app/oracle/oradata/EE/test_tablespace01.dbf' to '+DATA/EE/DATAFILE/test_tablespace01.dbf';

Database altered.

SQL> alter database recover datafile 5; 

Database altered.

SQL> alter database datafile 5 online ; 

Database altered.


SQL> select file_name, file_id, online_status from dba_data_files where file_id=5;

FILE_NAME					      FILE_ID ONLINE_
-------------------------------------------------- ---------- -------
+DATA/ee/datafile/test_tablespace01.dbf 		    5 ONLINE



-- check sql
alter session set nls_date_format='yyyy-mm-dd_hh24:mi:ss';     
select * from v$sqlarea a where A.Sql_fullText like '%TICKETRECORD_HIST%';
select sql_text, module, to_char( last_active_time, 'yyyy-mm-dd_hh24:mi:ss' )  from v$sqlarea a where A.Sql_fullText like '%TICKETRECORD_HIST%';



-- 1. 原因是OCR 区挂载失败，导致CRS daemon异常
[grid]$crs_stat -t
CRS-0184: Cannot communicate with the CRS daemon.

[oragrid]$which crs_stat
/oracle/11.2.0/grid/gridhome/bin/crs_stat
[oragrid]$/oracle/11.2.0/grid/gridhome/bin/crs_stat -t
CRS-0184: Cannot communicate with the CRS daemon.


-- 2. log 查异常原因
[oragrid:/oracle/11.2.0/grid/gridhome/log/hostname/crsd]$vi crsd.log 


-- 3.  ocr是oracle集群的注册文件，位于asm
[oragrid ~]$ocrcheck 
PROT-602: Failed to retrieve data from the cluster registry
PROC-26: Error while accessing the physical storage


-- 4.  查看diskgroup并尝试挂载OCR分区
SQL> select name,state from v$asm_diskgroup;

NAME
--------------------------------------------------------------------------------
STATE
---------------------------------
ARCDG1
MOUNTED

DATADG1
MOUNTED

OCR
DISMOUNTED


SQL> alter diskgroup ocr mount;

Diskgroup altered.


[oragrid]$asmcmd
ASMCMD> lsdg
State    Type    Rebal  Sector  Block       AU  Total_MB  Free_MB  Req_mir_free_MB  Usable_file_MB  Offline_disks  Voting_files  Name
MOUNTED  EXTERN  N         512   4096  1048576   1023986   601547                0          601547              0             N  ARCDG1/
MOUNTED  EXTERN  N         512   4096  1048576   2559965  1850805                0         1850805              0             N  DATADG1/
MOUNTED  NORMAL  N         512   4096  1048576      3069     2143             1023             560              0             Y  OCR/
ASMCMD> exit


-- 需要用root权限，否则报错如下：
[oragrid]$ocrcheck 
Status of Oracle Cluster Registry is as follows :
	 Version                  :          3
	 Total space (kbytes)     :     262120
	 Used space (kbytes)      :       3172
	 Available space (kbytes) :     258948
	 ID                       : 1572689525
	 Device/File Name         :       +OCR
                                    Device/File integrity check succeeded

                                    Device/File not configured

                                    Device/File not configured

                                    Device/File not configured

                                    Device/File not configured

	 Cluster registry integrity check succeeded

	 Logical corruption check bypassed due to non-privileged user


-- root运行
[oragrid]$sudo su - 
[root ~]# /oracle/11.2.0/grid/gridhome/bin/ocrcheck
Status of Oracle Cluster Registry is as follows :
	 Version                  :          3
	 Total space (kbytes)     :     262120
	 Used space (kbytes)      :       3172
	 Available space (kbytes) :     258948
	 ID                       : 1572689525
	 Device/File Name         :       +OCR
                                    Device/File integrity check succeeded

                                    Device/File not configured

                                    Device/File not configured

                                    Device/File not configured

                                    Device/File not configured

	 Cluster registry integrity check succeeded

	 Logical corruption check succeeded



-- 这个会失败， 尝试启动crs，但失败。只能启动cluster
[root ~]# /oracle/11.2.0/grid/gridhome/bin/crsctl start crs
CRS-4640: Oracle High Availability Services is already active
CRS-4000: Command Start failed, or completed with errors.
[root ~]# /oracle/11.2.0/grid/gridhome/bin/crsctl start cluster
CRS-2672: Attempting to start 'ora.crsd' on 'db2'
CRS-2676: Start of 'ora.crsd' on 'db2' succeeded


-- 处理最终结果，target和state一致，并且有rac1和rac2的信息

[oragrid]$crs_stat -t
Name           Type           Target    State     Host        
------------------------------------------------------------
ora.ARCDG1.dg  ora....up.type ONLINE    ONLINE    db1 
ora.DATADG1.dg ora....up.type ONLINE    ONLINE    db1 
ora....ER.lsnr ora....er.type ONLINE    ONLINE    db1 
ora....N1.lsnr ora....er.type ONLINE    ONLINE    db2 
ora.OCR.dg     ora....up.type ONLINE    ONLINE    db1 
ora.asm        ora.asm.type   ONLINE    ONLINE    db1 
ora....SM1.asm application    ONLINE    ONLINE    db1 
ora....B1.lsnr application    ONLINE    ONLINE    db1 
ora....db1.gsd application    OFFLINE   OFFLINE               
ora....db1.ons application    ONLINE    ONLINE    db1 
ora....db1.vip ora....t1.type ONLINE    ONLINE    db1 
ora....SM2.asm application    ONLINE    ONLINE    db2 
ora....B2.lsnr application    ONLINE    ONLINE    db2 
ora....db2.gsd application    OFFLINE   OFFLINE               
ora....db2.ons application    ONLINE    ONLINE    db2 
ora....db2.vip ora....t1.type ONLINE    ONLINE    db2 
ora.cvu        ora.cvu.type   ONLINE    ONLINE    db1 
ora.gsd        ora.gsd.type   OFFLINE   OFFLINE               
ora....network ora....rk.type ONLINE    ONLINE    db1 
ora.oc4j       ora.oc4j.type  ONLINE    ONLINE    db2 
ora.ons        ora.ons.type   ONLINE    ONLINE    db1 
ora....ry.acfs ora....fs.type ONLINE    ONLINE    db1 
ora.scan1.vip  ora....ip.type ONLINE    ONLINE    db2 
ora.zjzzdb.db  ora....se.type ONLINE    ONLINE    db1 


-- 观察超过1分钟以上的holder会话
SELECT l.inst_id,DECODE(l.request,0,'Holder: ','Waiter: ')||l.sid,s.serial#, s.machine, s.program,to_char(s.logon_time,'yyyy-mm-dd hh24:mi:ss'),l.id1, l.id2, l.lmode, l.request, l.type, s.sql_id,s.sql_child_number, s.prev_sql_id,s.prev_child_number
FROM gV$LOCK l , gv$session s 
 WHERE (l.id1, l.id2, l.type) IN (SELECT id1, id2, type FROM GV$LOCK WHERE request>0)
 and l.inst_id=s.inst_id and l.sid=s.sid
ORDER BY l.inst_id,l.id1, l.request;

-- 查询上述超过1分钟以上会话的SQL ID对应的SQL语句
select distinct piece,sql_text from gv$sqltext where sql_id='&sql_id' order by piece asc;

-- 查询到当时的传入参数
select name,position,datatype_string,value_string from dba_hist_sqlbind
where sql_id='&sqlid' order by snap_id,name,position;

-- 勒索病毒
select 'DROP TRIGGER '||owner||'."'||TRIGGER_NAME||'";' from dba_triggers where
TRIGGER_NAME like  'DBMS_%_INTERNAL%'
union all
select 'DROP PROCEDURE '||owner||'."'||a.object_name||'";' from DBA_PROCEDURES a
where a.object_name like 'DBMS_%_INTERNAL% '
/

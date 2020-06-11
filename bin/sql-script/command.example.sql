-- ------------------------------
-- storage and multipath
-- ------------------------------

--check
mdadm --detail /dev/md0


-- create
mdadm --create --verbose /dev/md0 --level=10 --raid-devices=4 /dev/sdb /dev/sdc /dev/sdd /dev/sde --spare-devices=1 /dev/sdf
mdadm --detail /dev/md0

-- save
mdadm --verbose --detail -scan > /etc/mdadm.conf

--restore other machinne?
cat /etc/mdadm.conf
mdadm --assemble /dev/md0

-- stop and remove
mdadm --stop /dev/md0
mdadm --remove /dev/md0
mdadm --zero-superblock /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf

-- lvm
pvcreate /dev/md0
vgcreate storage /dev/md0
lvcreate -n data -L 25GiB storage
lvcreate -n fra -L 5GiB storage
lvcreate -n ocr1 -L 1GiB storage
lvcreate -n ocr2 -L 1GiB storage
lvcreate -n ocr3 -L 1GiB storage

---

-- scsi-taget as service

--install
yum -y install scsi-target-utils sg3_utils

--config /etc/tgt/targets.conf 
default-driver iscsi
<target iqn.2020-03.com.example:storage.target4>
        backing-store /dev/mapper/storage-orc1
        backing-store /dev/mapper/storage-orc2
        backing-store /dev/mapper/storage-orc3
        write-cache on
        initiator-address 192.168.0.1
        initiator-address 192.168.1.1
        initiator-address 192.168.0.2
        initiator-address 192.168.1.2
</target>

<target iqn.2020-04.com.example:storage.data>
        backing-store /dev/mapper/storage-data
        write-cache on
        initiator-address 192.168.0.1
        initiator-address 192.168.1.1
        initiator-address 192.168.0.2
        initiator-address 192.168.1.2
</target>


-- start
service tgtd start
tgt-admin --update ALL --force

-- check
tgt-admin --show


-- iscsi-initiator
yum install iscsi-initiator-utils

--discover
sudo iscsiadm -m discovery -t sendtargets -p storage-priv1
sudo iscsiadm -m discovery -t sendtargets -p storage-priv2

-- check
iscsiadm -m node -P 0


--restart iscsi
sudo /etc/init.d/iscsi restart

-- mulipath
yum install device-mapper-multipath
/sbin/mpathconf --enable
/etc/init.d/multipathd restart
multipath -ll

-- /etc/multipath.conf


defaults {
        user_friendly_names yes
        getuid_callout "/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/%n"
}

blacklist {
        devnode "^(ram|raw|loop|fd|md|dm-|sr|scd|st)[0-9]*"
}

multipaths {
        multipath {
                wwid      1IET_00010001
                alias     storage-orc1
        }
        multipath {
                wwid      1IET_00010002
                alias     storage-orc2
        }
        multipath {
                wwid      1IET_00010003
                alias     storage-orc3
        }
        multipath {
                wwid      1IET_00020001
                alias     storage-data
        }
        multipath {
                wwid      1IET_00080001
                alias     storage-fra
        }
}



---



mdadm --verbose --detail /dev/md0
mdadm --add /dev/md0 /dev/sdg /dev/sdi /dev/sdh
mdadm --grow /dev/md0 --raid-devices=7
mdadm --detail /dev/md0
/etc/init.d/tgtd stop
pvresize /dev/md0
vgdisplay
lvextend -l +100%FREE storage-fra
lvextend -L 20G storage-fra
/etc/init.d/tgtd start


sudo /etc/init.d/iscsi stop
sudo /etc/init.d/multipathd stop
# sudo multipathd --disable
# sudo multipathd -k'resize map storage-fra'
sql> select name, total_mb/(1024) "Total GiB" from v$asm_diskgroup;
sql> alter diskgroup FRA resize all;

sudo /etc/init.d/oracleasm start

/etc/init.d/oracleasm configure
oracleasm scandisks
oracleasm listdisks
/usr/sbin/asmtool -C -l /dev/oracleasm -n FRA -s /dev/mapper/storage-fra -a force=yes
oracleasm listdisks
/usr/sbin/asmtool -C -l /dev/oracleasm -n DATA2 -s /dev/mapper/storage-data -a force=yes
/usr/sbin/asmtool -C -l /dev/oracleasm -n OCR1 -s /dev/mapper/storage-ocr1 -a force=yes
/usr/sbin/asmtool -C -l /dev/oracleasm -n OCR2 -s /dev/mapper/storage-ocr2 -a force=yes
/usr/sbin/asmtool -C -l /dev/oracleasm -n OCR3 -s /dev/mapper/storage-ocr3 -a force=yes
oracleasm listdisks
ls -l /dev/oracleasm/
ls -l /dev/oracleasm/disks/
/etc/init.d/oracleasm --help
/etc/init.d/oracleasm listdisks

-- kfod - Kernel Files OSM Disk
kfod disk=all
kfod status=true g=OCR
-- kfed - Kernel Files metadata EDitor
kfed read ORCL:ORC1
kfed read ORCL:ORC1 | grep -P "kfdhdb.hdrsts|kfdhdb.dskname|kfdhdb.grpname|kfdhdb.fgname|kfdhdb.secsize|blksize|driver.provstr|kfdhdb.ausize"
-- amdu - ASM Metadata Dump Utility
--  Dumps metadata for ASM disks
--  Extract the content of ASM files even DG isn't mounted
asmcmd lsdg | grep -i ocr
amdu -diskstring 'ORCL:*' -dump 'OCR'




-- ------------------------------
-- parameter
-- ------------------------------

-- Spool on/off
spool /tmp/out.txt;
spool off;

set linesize 9999
set pagesize 100
col 1 format a15


-- clear buffer and cache
alter system flush buffer_cache


-- DB_NAME, DB_UNIQUE_NAME, SERVICE_NAMES, INSTANCE_NAME, and $ORACLE_SID
-- http://logic.edchen.org/db_name-db_unique_name-service_names-instance_name-and-oracle_sid/

DB_NAME (Enterprise-wide Name) = $ORACLE_SID (Installation-time)
DB_UNIQUE_NAME (Site-wide Name) = DB_NAME (Startup-time) SERVICE_NAMES = DB_UNIQUE_NAME
INSTANCE_NAME (Server-wide Name) INSTANCE_NAME = $ORACLE_SID
-- 

└── COMPDB 			-- DB_NAME, DB_UNIQUE_NAME, SERVICE_NAMES, INSTANCE_NAME, and $ORACLE_SID
    ├── PRIMDB		-- DB_UNIQUE_NAME (Site-wide Name) = DB_NAME (Startup-time) SERVICE_NAMES = DB_UNIQUE_NAME
    │   ├── PRIMDB1		-- INSTANCE_NAME (Server-wide Name) INSTANCE_NAME = $ORACLE_SID
    │   └── PRIMDB2
    └── STANDB
        ├── STANDB1
        └── STANDB2


-- sga/pga 比例 
-- 假设主机的总物理内存是100G。
-- 20G -- 操作系统及其他预留
-- 64G -- Oracle的SGA 100*0.8*0.8
-- 16G -- Oracle的PGA 100*0.8*0.2

-- alert log location
show parameter DIAGNOSTIC_DEST
DIAGNOSTIC_DEST/diag/rdbms/DB_NAME/ORACLE_SID/trace/alert_${ORACLE_SID}.log

show parameter BACKGROUND_DUMP_DEST
-- or --
ORACLE_HOME/rdbms/trace

-- pfile 
$ORACLE_HOME/dbs/init/init$PID.ora

-- tnsnames
$ORACLE_HOME/network/admin/tnsnames.ora


-- startup  启动数据库实例
sqlplus / as sysdba
startup

SQL> startup nomount         ------------started, instance up with spfile
SQL> alter database mount   ------------mounted, instance mount with controlfile
SQL> alter database open     ------------open,  instance open with datafiles


-- shutdown 关闭数据库实例：
sqlplus / as sysdba
shutdown immediate
shutdown abort


-- start listener  启动监听
$ lsnrctl start
$ lsnrctl status
$ lsnrctl stop
-- 检查谁在运行监听
ps -ef | grep tnslsnr

-- 增加静态监听  $ORACLE_HOME/admin/network/listener.ora 添加
SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
     (ORACLE_HOME = /u01/app/oracle/product/11.2.0/db_1 )
     (SID_NAME = rac1 )
     (GLOBAL_DBNAME= PRIDB )
    )
    (SID_DESC =
      (GLOBAL_DBNAME = PRIDB_DGMGRL)
      (ORACLE_HOME = /u01/app/oracle/product/11.2.0/db_1)
      (SID_NAME = rac1 )
      (SERVICE_NAME = PRIDB)
    )
  )


-- enable flashback
-- minutes 1440 minutes = 1day
ALTER SYSTEM SET DB_FLASHBACK_RETENTION_TARGET=4320;
ALTER DATABASE FLASHBACK ON;
SELECT FLASHBACK_ON FROM V$DATABASE;


-- recyclebin manage
show parameter recyclebin;
show recyclebin;   -- 显示垃圾桶内容
drop table name purge;  --drop表不放垃圾桶

Purge tablespace tablespace_name -- 用于清空表空间的Recycle Bin
Purge tablespace tablespace_name user user_name -- 清空指定表空间的Recycle Bin中指定用户的对象
Purge recyclebin                                --删除当前用户的Recycle Bin中的对象
Purge dba_recyclebin                            --删除所有用户的Recycle Bin中的对象，该命令要sysdba权限
Drop table table_name purge                     -- 删除对象并且不放在Recycle Bin中，即永久的删除，不能用Flashback恢复。
Purge index recycle_bin_object_name             -- 当想释放Recycle bin的空间，又想能恢复表时，可以通过释放该对象的index所占用的空间来缓解空间压力。 因为索引是可以重建的。
PURGE TABLE TABLE_NAME                          --删除回收站中指定对象
PURGE TABLE "BIN$04LhcpndanfgMAAAAAANPw==$0";   --使用其回收站中的名称：

-- recyclebin flashback
flashback table table_name to before drop;                          -- 还原回收站被删除的表、索引等对象， 是通过Flashback Drop实现的
flashback table table_name to before drop rename to new_table_name; --闪回到新的名字
-- Flashback Drop注意事项
1: 只能用于非系统表空间和本地管理的表空间。 在系统表空间中，表对象删除后就真的从系统中删除了，而不是存放在回收站中。
2: 对象的参考约束不会被恢复，指向该对象的外键约束需要重建。
3: 对象能否恢复成功，取决于对象空间是否被覆盖重用。
4: 当删除表时，依赖于该表的物化视图也会同时删除，但是由于物化视图并不会放入recycle binzhong，因此当你执行flashback drop时，并不能恢复依赖其的物化视图。需要DBA手工重建。
5: 对于回收站（Recycle Bin）中的对象，只支持查询。不支持任何其他DML、DDL等操作。






-- EMi 
-- create https://dbatricksworld.com/oracle-enterprise-manager-failed-to-start-oc4j-configuration-issue-configure-enterprise-manager-database-control-manually-with-enterprise-manager-configuration-assistant/
emca -config dbcontrol db -repos create

-- EM/oem start 
$ emctl start dbconsole
$ emctl stop dbconsole
$ emctl status agent


-- server ip and hostname
select utl_inaddr.get_host_address(host_name), host_name from v$instance;
-- client ip and hostname
select sys_context('USERENV', 'HOST') from dual;
select sys_context('USERENV', 'IP_ADDRESS') from dual;


-- which spfile
show parameter spfile;


-- check character set
select value from nls_database_parameters where parameter='NLS_CHARACTERSET';


-- show schemas
select distinct owner from dba_segments where owner in (select username from dba_users where default_tablespace not in ('SYSTEM','SYSAUX') );


-- aix 挂载nfs
mount -o rw,bg,hard,intr,proto=tcp,vers=3,rsize=65536,wsize=65536,timeo=600 172.16.45.200:/volume1/Server_nfs01/dg83 /mnt/nas


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
ALTER USER user_name IDENTIFIED BY NEWPASSWORD account unlock;
-- change user unlock
ALTER USER user_name account unlock;


-- show account not work
SELECT username, account_status, created, lock_date, expiry_date FROM dba_users WHERE account_status != 'OPEN';


-- 查询登陆失败 DBA_AUDIT_TRAIL displays all audit trail entries.
alter session set nls_date_format='yyyy-mm-dd_hh24:mi:ss';
select * from DBA_AUDIT_TRAIL where Returncode <> 0 order by Timestamp; 


-- truncate aud$
select count(1) from sys.aud$;
select object_name,owner,object_type from dba_objects where object_name='AUD$';
truncate table sys.aud$ reuse storage;



-- oracle password file, 用于判断是否让远程登陆sys用户
SQL> select * from v$pwfile_users; 

USERNAME                       SYSDB SYSOP SYSAS
------------------------------ ----- ----- -----
SYS                            TRUE  TRUE  FALSE


-- 如果没有，就创建密码文件, default location $ORACLE_HOME/dbs/orapw$ORACLE_SID 
orapwd file=orapw[SID] password=oracle


--Oracle / PLSQL: Grant/Revoke Privileges
-- Grant Privileges on Table
GRANT privileges ON object TO user;
GRANT SELECT, INSERT, UPDATE, DELETE ON suppliers TO smithj;
GRANT SELECT ON suppliers TO public;
-- Revoke Privileges on Table
REVOKE privileges ON object FROM user;
REVOKE DELETE ON suppliers FROM anderson;
REVOKE ALL ON suppliers FROM public;
-- Grant Privileges on Functions/Procedures
GRANT EXECUTE ON object TO user;
GRANT EXECUTE ON Find_Value TO smithj;
GRANT EXECUTE ON Find_Value TO public;
-- Revoke Privileges on Functions/Procedures
REVOKE EXECUTE ON object FROM user;
REVOKE execute ON Find_Value FROM anderson;
REVOKE EXECUTE ON Find_Value FROM public;


-- autotrace
set autotrace traceonly statistics; 
set autotrace off;
-- 
drop role plustrace;
create role plustrace;
grant select on v_$sesstat to plustrace;
grant select on v_$statname to plustrace;
grant select on v_$mystat to plustrace;
grant plustrace to dba with admin option;
grant plustrace to SCOTT;


-- turn off Oracle password expiration?
--  https://stackoverflow.com/questions/1095871/how-do-i-turn-off-oracle-password-expiration
SELECT profile FROM dba_users WHERE username = upper('&currentuser');
alter profile <profile_name> limit password_life_time UNLIMITED;
select resource_name,limit from dba_profiles where profile='<profile_name>';
-- for developer
ALTER PROFILE "DEFAULT" LIMIT PASSWORD_VERIFY_FUNCTION NULL;
ALTER user user_name identified by new_password account unlock;


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
select dest_name,status,destination from V$ARCHIVE_DEST where DESTINATION is not null;
show parameter recover
show parameter log_archive_dest

-- change recover location
alter system set db_recovery_file_dest='+DATA' scope=spfile sid='*'; 

--check recovery space usage
select * from v$recovery_area_usage ; 

-- show parameter 
show parameter db_recovery
show parameter db_create



-- ------------------------------
-- USER and schema
-- ------------------------------

-- ORA-28002: the password will expire within 7 days
SELECT profile FROM dba_users WHERE username = upper('&currentuser'); 
--
SYS> select resource_name,limit from dba_profiles where profile='DEFAULT' and RESOURCE_NAME='PASSWORD_LIFE_TIME';
-- 用户不过期
ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
-- 尝试不退出
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED;



-- check account expire day
SELECT USERNAME, EXPIRY_DATE FROM DBA_USERS;



-- check user privileges 
-- Granted Roles:
SELECT * FROM DBA_ROLE_PRIVS WHERE GRANTEE = '&user';

-- Privileges Granted Directly To User:
SELECT * FROM DBA_TAB_PRIVS WHERE GRANTEE = '&user';

-- Privileges Granted to Role Granted to User:
SELECT * FROM DBA_TAB_PRIVS  WHERE GRANTEE IN (SELECT granted_role FROM DBA_ROLE_PRIVS WHERE GRANTEE = '&user');

-- Granted System Privileges:
SELECT * FROM DBA_SYS_PRIVS WHERE GRANTEE = '&user'; 


-- create user/schema
select * from dba_temp_files;
CREATE USER username IDENTIFIED BY password DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP PROFILE default ACCOUNT unlock;
GRANT CREATE SESSION, CREATE TABLE, CREATE TRIGGER, CREATE SEQUENCE, CREATE VIEW, CREATE PROCEDURE TO username;  
GRANT CONNECT, RESOURCE TO username ; 
GRANT UNLIMITED TABLESPACE TO users;
-- CONNECT to assign privileges to the user through attaching the account to various roles
-- RESOURCE role (allowing the user to create named types for custom schemas)
-- DBA  which allows the user to not only create custom named types but alter and destroy them as well
-- ensure our new user has disk space allocated in the system to actually create or modify tables and data


-- create READ_ONLY role.
CREATE ROLE CKS_RO_ROLE;

-- grant CKS tables to CKS_RO_ROLE
BEGIN
  FOR x IN (SELECT * FROM dba_tables WHERE owner='CKS' and table_name not like 'TMP_%')
  LOOP
    EXECUTE IMMEDIATE 'GRANT SELECT ON CKS.' || x.table_name || ' TO CKS_RO_ROLE';
    -- DBMS_OUTPUT.put_line('got: ' || x.table_name);
  END LOOP;
END;

-- grant to user CKSES
GRANT CKS_RO_ROLE TO CKSES;


-- drop user 
-- In order to drop a user, you must have the Oracle DROP USER system privilege. The command line syntax for dropping a user can be seen below:
DROP USER edward CASCADE;
DROP TABLESPACE tablespacename INCLUDING CONTENTS AND DATAFILES;
-- check active and kill
select s.sid, s.serial#, s.status, p.spid from v$session s, v$process p where s.username = '&user' and p.addr (+) = s.paddr;
alter system kill session '&sid,&serial,@&inst_id' immediate;
-- user and space mb
select owner, TABLESPACE_NAME, sum(bytes)/1024/1024 MB from dba_segments group by owner, TABLESPACE_NAME ;
select tablespace_name from all_tables where owner = '&username';


-- ------------------------------
-- RMAN
-- ------------------------------


-- rman backup info
select start_time, status, input_type, output_bytes_display, time_taken_display from v$rman_backup_job_details order by start_time desc;


-- create db by manual 手动建库
--https://www.oracle-dba-online.com/creating_the_database.htm
--create pfile
cat > init.ora <<EOF
DB_NAME=ORADB
DB_BLOCK_SIZE=8192
CONTROL_FILES='/u01/app/oracle/oradata/ORADB/controlfileORADR.ctl','/u01/app/oracle/flash_recovery_area/ORADB/controlfileORADR.ctl'
UNDO_TABLESPACE=UNDOTBS
UNDO_MANAGEMENT=AUTO
SGA_TARGET=500M
PGA_AGGREGATE_TARGET=100M
LOG_BUFFER=5242880
standby_file_management=auto
DB_RECOVERY_FILE_DEST=/u01/app/oracle/flash_recovery_area
DB_RECOVERY_FILE_DEST_SIZE=2G
EOF
--createdb.sql
-- 其中这个database name是db_name
CREATE DATABASE OLTP3140
   USER SYS IDENTIFIED BY oracle
   USER SYSTEM IDENTIFIED BY oracle
   LOGFILE GROUP 1 ('/u01/app/oracle/oradata/unique_db_name/onlinelog/redo01.log') SIZE 100M,
           GROUP 2 ('/u01/app/oracle/oradata/unique_db_name/onlinelog/redo02.log') SIZE 100M,
           GROUP 3 ('/u01/app/oracle/oradata/unique_db_name/onlinelog/redo03.log') SIZE 100M
   MAXLOGFILES 5
   MAXLOGMEMBERS 5
   MAXLOGHISTORY 1
   MAXDATAFILES 100
   CHARACTER SET AL32UTF8
   EXTENT MANAGEMENT LOCAL
   DATAFILE '/u01/app/oracle/oradata/unique_db_name/datafile/system01.dbf' SIZE 325M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
   SYSAUX DATAFILE '/u01/app/oracle/oradata/unique_db_name/datafile/sysaux01.dbf' SIZE 325M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
   DEFAULT TABLESPACE users
      DATAFILE '/u01/app/oracle/oradata/unique_db_name/datafile/users01.dbf'
      SIZE 500M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
   DEFAULT TEMPORARY TABLESPACE tempts1 
      TEMPFILE '/u01/app/oracle/oradata/unique_db_name/datafile/temp01.dbf'
      SIZE 20M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
   UNDO TABLESPACE undotbs
      DATAFILE '/u01/app/oracle/oradata/unique_db_name/datafile/undotbs01.dbf'
      SIZE 200M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;
-- create the db in start
startup nomount pfile='/home/oracle/init.ora';
@/home/oracle/createdb.sql
create tablespace users datafile '/u01/app/oracle/oradata/unique_db_name/datafile/user01.dbf' size 100m; 
create spfile from pfile='/home/oracle/init.ora'; 
-- creates all the data dictionary views,
@?/rdbms/admin/catalog.sql
-- creates system specified stored procedures
@?/rdbms/admin/catproc.sql
-- creates the default roles and profiles.
@?/sqlplus/admin/pupbld.sql
-- The utlrp.sql script can be called to recompile all objects within the database 
@?/rdbms/admin/utlrp.sql
--
CREATE USER SCOTT IDENTIFIED BY scott DEFAULT TABLESPACE users PROFILE DEFAULT ACCOUNT UNLOCK;
GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE VIEW TO SCOTT;
GRANT CONNECT, RESOURCE TO SCOTT ;
GRANT UNLIMITED TABLESPACE TO SCOTT;
-- create listener
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
-- and config the /etc/oratab
orapwd file=${ORACLE_HOME}/dbs/orapw${ORACLE_SID} password=oracle
-- config
srvctl remove database -d oradr
srvctl add database -d ORADR -o /u01/app/oracle/product/11.2.0/dbhome_1

-- rac
-- init.ora
rac2.__db_cache_size=41943040
rac1.__db_cache_size=41943040
rac2.__java_pool_size=4194304
rac1.__java_pool_size=4194304
rac2.__large_pool_size=8388608
rac1.__large_pool_size=8388608
rac2.__oracle_base='/u01/app/oracle'#ORACLE_BASE set from environment
rac1.__oracle_base='/u01/app/oracle'#ORACLE_BASE set from environment
rac2.__pga_aggregate_target=184549376
rac1.__pga_aggregate_target=184549376
rac1.__sga_target=213909504
rac2.__sga_target=213909504
rac2.__shared_io_pool_size=0
rac1.__shared_io_pool_size=0
rac2.__shared_pool_size=150994944
rac1.__shared_pool_size=150994944
rac2.__streams_pool_size=0
rac1.__streams_pool_size=0
*.archive_lag_target=0
*.audit_file_dest='/u01/app/oracle/admin/PRIDB/adump'
*.audit_trail='db'
*.cluster_database=false
*.compatible='11.2.0.4.0'
*.control_files='+DATA/PRIDB/CONTROLFILE/control.ctl'
*.db_block_size=8192
*.db_create_file_dest='+DATA'
*.db_domain=''
*.db_file_name_convert='+DATA','+DATA'
*.db_name='ORCL'
*.db_recovery_file_dest_size=10g
*.db_recovery_file_dest='+DATA'
*.db_unique_name='PRIDB'
*.dg_broker_config_file1='+DATA/PRIDB/datafile/dgbroker1PRIDB.dat'
*.dg_broker_config_file2='+DATA/PRIDB/datafile/dgbroker2PRIDB.dat'
*.dg_broker_start=TRUE
*.diagnostic_dest='/u01/app/oracle'
*.fal_client='PRIDB'
*.fal_server='STBDB'
rac2.instance_number=2
rac1.instance_number=1
*.log_archive_config='DG_CONFIG=(PRIDB,STBDB)'
*.log_archive_dest_1='LOCATION=USE_DB_RECOVERY_FILE_DEST VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=PRIDB'
*.log_archive_dest_2='SERVICE=ORASTBDB LGWR ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=STBDB'
*.log_archive_dest_3=''
*.log_archive_dest_state_2='ENABLE'
rac1.log_archive_format='%t_%s_%r.dbf'
rac2.log_archive_format='%t_%s_%r.dbf'
*.log_archive_max_processes=10
*.log_archive_min_succeed_dest=1
rac1.log_archive_trace=0
rac2.log_archive_trace=0
*.log_file_name_convert='+DATA','+DATA'
*.memory_max_target=421527552
*.memory_target=421527552
*.open_cursors=300
*.processes=150
*.remote_listener='rac-scan:1521'
*.remote_login_passwordfile='exclusive'
*.sga_max_size=0
*.standby_file_management='AUTO'
rac2.thread=2
rac1.thread=1
rac2.undo_tablespace='UNDOTBS2'
rac1.undo_tablespace='UNDOTBS1'

-- createdb.sql
CREATE DATABASE orcl
   USER SYS IDENTIFIED BY oracle
   USER SYSTEM IDENTIFIED BY oracle
   LOGFILE GROUP 1 ('+DATA/PRIDB/onlinelog/redo01.log') SIZE 100M,
           GROUP 2 ('+DATA/PRIDB/onlinelog/redo02.log') SIZE 100M,
           GROUP 3 ('+DATA/PRIDB/onlinelog/redo03.log') SIZE 100M,
           GROUP 4 ('+DATA/PRIDB/onlinelog/redo04.log') SIZE 100M
   MAXLOGFILES 5
   MAXLOGMEMBERS 5
   MAXLOGHISTORY 1
   MAXDATAFILES 100
   CHARACTER SET AL32UTF8
   EXTENT MANAGEMENT LOCAL
   DATAFILE '+DATA/PRIDB/DATAFILE/system01.dbf' SIZE 325M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
   SYSAUX DATAFILE '+DATA/PRIDB/DATAFILE/sysaux01.dbf' SIZE 325M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
   DEFAULT TABLESPACE users
      DATAFILE '+DATA/PRIDB/DATAFILE/users01.dbf'
      SIZE 500M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
   DEFAULT TEMPORARY TABLESPACE tempts1
      TEMPFILE '+DATA/PRIDB/TEMPFILE/temp01.dbf'
      SIZE 20M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
   UNDO TABLESPACE UNDOTBS1
      DATAFILE '+DATA/PRIDB/DATAFILE/undotbs01.dbf'
      SIZE 200M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;
-- add undo to rac2
create UNDO TABLESPACE UNDOTBS2 DATAFILE '+data/PRIDB/datafile/undotbs02.dbf' SIZE 200M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;
-- add logfile
alter database add logfile thread 2 group 5 ('+DATA/pridb/onlinelog/redo05.log') size 100M ,group 6 ('+DATA/pridb/onlinelog/redo06.log') size 100M, group 7 ('+DATA/pridb/onlinelog/redo07.log') size 100M, group 8 ('+DATA/pridb/onlinelog/redo08.log') size 100M ;
-- define cluster database
alter system set cluster_database=TRUE sid='*' scope=spfile ;
alter system set cluster_database_instances=2 sid='*' scope=spfile;
alter database enable public thread 2;
-- archivelog 
alter database archivelog mode;
-- register in crs
srvctl add database -d pridb -r PRIMARY -n orcl -o $ORACLE_HOME
srvctl add instance -d pridb -i rac1 -n rac1
srvctl add instance -d pridb -i rac2 -n rac2





-- 从现有dg添加另外一个adg1

-- pridb修改参数
-- 从原来dg添加一个adg1 DG_CONFIG=(oradb,dg) 改为 DG_CONFIG=(oradb,dg,adg1)
alter system set LOG_ARCHIVE_CONFIG='DG_CONFIG=(oradb,dg,adg1)' sid='*' scope=both;
-- 添加一个LOG_ARCHIVE_DEST
alter system set LOG_ARCHIVE_DEST_3='SERVICE=adg1 LGWR ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=adg1' sid='*' scope=both;


-- stbydb的设置， 先将recovery、fal、log、name的参数设置好
--db_unique_name=adg1
cat > ~/init.ora <<EOF
*.compatible='11.2.0.4.0'
*.control_files='+DATA/adg1/controlfile/current.256.1013424367'
*.db_recovery_file_dest='+DATA'
*.db_recovery_file_dest_size=10G
*.db_unique_name='adg1'
*.db_name='oradb'
*.memory_max_target=400M
*.memory_target=400M
*.db_file_name_convert='+DATA','+DATA'
*.fal_client=adg1
*.fal_server=oradb
*.log_archive_config='DG_CONFIG=(adg1,oradb)'
*.log_archive_dest_1='LOCATION=USE_DB_RECOVERY_FILE_DEST VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=adg1'
*.log_archive_dest_2='SERVICE=oradb LGWR ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=oradb'
*.log_file_name_convert='+DATA','+DATA','+ARCH','+ARCH'
EOF

SQL> startup nomount pfile='/home/oracle/init.ora';


--增加静态监听， 修改 grid的 $ORACLE_HOME/network/admin/listener.ora，添加以下内容
SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
     (ORACLE_HOME = /u01/app/oracle/product/11.2.0/dbhome_1)
     (SID_NAME = oradg)
     (GLOBAL_DBNAME=dg)
    )
 )

-- 用于rman的auxiliary(clone from source instance to auxiliary instance), 这里需要1、nomount状态、并且开启监听（也就是静态）
$ rman target sys/oracle@oradb auxiliary sys/oracle@adg1
SQL> startup nomount pfile='/home/oracle/init.ora';
RMAN> duplicate target database for standby from active database;
SQL> alter database add standby logfile;
SQL> alter database open;
SQL> recover managed standby database using current logfile disconnect from session;
SQL> alter database recover managed standby database cancel;
SQL> shutdown immediate

-- tnsnames.ora
OLTP=
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 172.16.70.71)(PORT = 1521))
    )
    (CONNECT_DATA = (SERVICE_NAME = OLTP))
  )


--  拷贝数据库：

和上述一样，从standby库中拷贝到remote端的client库, 和dg一样，1 需要设置静态监听，2 convert参数，但不需要设置dest, archive, log参数
拷贝库的时候应该也一样拷贝为dg只读（以免无意resetlogs）
拷贝的时候 
rman target sys/oracle@stbdb:1521/oradb auxiliary sys/oracle@remoteclient:1521/oradb
duplicate target database for standby from active database;
然后就可以尝试open，如果提示system不完整错误，就在主库 checkpoint 并将 archivelog拷贝到 remoteclient， 注册后即可。

ERROR at line 1:
ORA-10458: standby database requires recovery
ORA-01194: file 1 needs more recovery to be consistent
ORA-01110: data file 1:


-- backup archivelog today
run
{
allocate channel d1 device type disk format '/home/oracle/archivelog/%U.bkp';
backup archivelog from time 'sysdate-1';
}

--restore database with this archivelog
RMAN> catalog start with '/home/oracle/archivelog/';
recover database ;
recover database until SCN 1720014 ;
alter database open ; 


-- rman
$ rman target /

-- 列出rman备份
list backup; 

-- 列出 配置
show all; 

-- reset
CONFIGURE CONTROLFILE AUTOBACKUP clear;

--backup
BACKUP AS COMPRESSED BACKUPSET DATABASE PLUS ARCHIVELOG;

--enable controlfile autobackup, ( spfile autobackup by default );
CONFIGURE CONTROLFILE AUTOBACKUP ON;

-- 基于时间的备份保留策略 ( 3天 )
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 3 DAYS;

-- 基于备份份数保留策略 ( 3份 )
CONFIGURE RETENTION POLICY TO REDUNDANCY 3;

--  查看
report obsolete;
report need backup ; 
report schema; 
validate database plus archivelog ; 
list incarnation ; 
list backup summary; 

-- 异常和建议, 自动执行
list failure;  
advise failure;  
repair failure preview;
repair failure;


-- rman for dataguard
-- for the site where you don’t backup. It can be the standby or the primary.
-- rman on rac
RMAN> CONFIGURE SNAPSHOT CONTROLFILE NAME TO '+DATA/oradb/controlfile/snapcf_ORAPRIMDB.f';
-- rman on ADG
RMAN> CONFIGURE ARCHIVELOG DELETION POLICY TO APPLIED ON ALL STANDBY;
-- other example
DELETE ARCHIVELOG ALL COMPLETED BEFORE 'sysdate-1';
DELETE ARCHIVELOG ALL BACKED UP 2 TIMES to disk;
DELETE NOPROMPT ARCHIVELOG UNTIL SEQUENCE = 3790;


-- reset to a specific incarnation;
startup mount force
reset database to incarnation 4;
restore database; 
recover database until SCN 1010384 ; 
alter database open resetlogs ; 


-- change location with SET NEWNAME

-- specify the new location for each datafile
RUN
{
SET NEWNAME FOR DATAFILE '/u01/app/oracle/oradata/EE/system01.dbf' TO '/u01/app/oracle/oradata/new/system01.dbf';
SET NEWNAME FOR DATAFILE '/u01/app/oracle/oradata/EE/sysaux01.dbf' TO '/u01/app/oracle/oradata/new/sysaux01.dbf';
SET NEWNAME FOR DATAFILE '/u01/app/oracle/oradata/EE/undotbs01.dbf' TO '/u01/app/oracle/oradata/new/undotbs01.dbf';
SET NEWNAME FOR DATAFILE '/u01/app/oracle/oradata/EE/users01.dbf' TO '/u01/app/oracle/oradata/new/users01.dbf';
SET NEWNAME FOR DATAFILE '/u01/app/oracle/oradata/EE/redo01.log' TO '/u01/app/oracle/oradata/new/redo01.log';
SET NEWNAME FOR DATAFILE '/u01/app/oracle/oradata/EE/redo02.log' TO '/u01/app/oracle/oradata/new/redo02.log';
SET NEWNAME FOR DATAFILE '/u01/app/oracle/oradata/EE/redo03.log' TO '/u01/app/oracle/oradata/new/redo03.log';
RESTORE database ; 
}

-- https://docs.oracle.com/cd/E18283_01/backup.112/e10642/rcmdupad.htm
-- rman backup archivelog
-- backup archivelog all 和 plus archivelog 的区别

backup archivelog all;
    1.alter system archive log current;  归档当前日志 
    2.backup  archivelog all ; 备份所有归档日志

backup database plus archivelog
    1.alter system archive log current;  归档当前日志
    2.backup archivelog all；        备份所有归档日志
    3.backup database;          备份数据库
    4.alter system archive log current;  归档当前日志
    5.backup archivelog recently generated ;   备份刚生成的归档日志


-- for backup
-- 备份的时候指定路径。注意autobackup路径应该还是在recover directory

run
{
  allocate channel d1 device type disk format '/home/oracle/backup/%U.bkp';
  backup database plus archivelog; 
  release channel d1;
}


-- for restore
-- change location preview
run
{
SET NEWNAME FOR DATABASE TO '/u01/app/oracle/oradata/ORCL/%b'; 
restore database preview;
}


-- 完整例子，先set newname 指定 OS 数据库文件路径，然后使用switch调整controlfile的映射路径。
-- 11g以前，set newname只能指定datafile，之后就能设置for database（datafile和tempfile生效，但logfile不生效，需要在mount状态下调整logfile路径）

RMAN>
run
{
SET NEWNAME FOR DATABASE TO '/u01/app/oracle/oradata/ADG/%b'; 
restore database ;
SWITCH DATAFILE ALL;
SWITCH TEMPFILE ALL;  
}

SQLPLUS>
select name from v$datafile;
select name from v$tempfile;
select member from v$logfile;

-- alter database rename file '/u01/app/oracle/oradata/EE/redo01.log' to '/u01/app/oracle/oradata/ADG/redo01.log' ;
-- alter database rename file '/u01/app/oracle/oradata/EE/redo02.log' to '/u01/app/oracle/oradata/ADG/redo02.log' ;
-- alter database rename file '/u01/app/oracle/oradata/EE/redo03.log' to '/u01/app/oracle/oradata/ADG/redo03.log' ;

-- 如果设置了db_create参数，能自动生成log位置     *.db_create_file_dest='/u01/app/oracle/oradata';
alter database clear logfile group 1;
alter database clear logfile group 2;
alter database clear logfile group 3;
alter database clear logfile group 4;

alter database open resetlogs;


-- disable / remove after restore to single node.
select thread#, instance, status from v$thread
alter database disable thread 2; 

alter database drop logfile group 3;
alter database drop logfile group 4;




-- delete obsolete 

RMAN> CONFIGURE RETENTION POLICY TO REDUNDANCY 2;
delete obsolete ; 

-- delete expired
crosscheck archivelog all ;
delete expired archivelog all ; 



-- ------------------------------
-- ADG
-- ------------------------------

-- 查询
select recovery_mode from v$archive_dest_status where dest_id=2;
select protection_mode,database_role,open_mode from v$database;
select name,db_unique_name from v$database;
select max(sequence#) from v$archived_log; 
-- dg processes
select sequence#,status,thread#,block#,process,status from v$managed_standby;


-- start redo apply in the FOREGROUND, issue the following sql statement:
alter database recover managed standby database;

-- to start redo apply in the BACKGROUND, include the DISCONNECT keyword on the sql statement. for example:
alter database recover managed standby database disconnect;

-- to start real-time apply, include the using CURRENT LOGFILE clause on the sql statement. for example:
alter database recover managed standby database using current logfile disconnect;

-- Managed Standby Recovery Canceled
alter database recover managed standby database cancel;
-- Managed Standby Recovery finished
alter database recover managed standby database finish;



--create manual
-- primary应该产生standby controlfile，给standby mount状态进行rman
-- standby的路径应该由spfile的log_file_name_convert，db_file_name_convert进行调整，调整后会对rman restore 或者 rman duplicate有效

-- tnsnames on primary and standby

-- primary
sql> alter system set log_archive_config='DG_CONFIG=(PRIMARY,STANDBY)' scope=spfile; 
sql> alter system set log_archive_dest_1='LOCATION=USE_DB_RECOVERY_FILE_DEST VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=PRIMAY' scope=spfile;
sql> alter system set log_archive_dest_2='SERVICE=ADG LGWR ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=STANDBY' scope=spfile;
sql> shutdown immediate
sql> startup
rman> backup database plus archivelog;
sql> alter database create standby controlfile as '/home/oracle/controlfile.ctl';

-- standby
cat > ~/init.ora <<EOF
*.compatible='11.2.0.4.0'
*.control_files='/u01/app/oracle/oradata/STANDBY/controlfile/control01.ctl','/u01/app/oracle/flash_recovery_area/STANDBY/controlfile/control02.ctl'
*.db_recovery_file_dest='/u01/app/oracle/flash_recovery_area'
*.db_recovery_file_dest_size=10G
*.db_name='oradb'
*.memory_max_target=400M
*.memory_target=400M
*.db_unique_name='STANDBY'
*.standby_file_management=auto
*.fal_client=adg1
*.fal_server=oradb
*.log_archive_config='DG_CONFIG=(STANDBY,PRIMARY)'
*.log_archive_dest_1='LOCATION=USE_DB_RECOVERY_FILE_DEST VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=STANDBY'
*.log_archive_dest_2='SERVICE=PRIMARY LGWR ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=PRIMARY'
*.db_file_name_convert='/u01/app/oracle/oradata/PRIMARY/datafile','/u01/app/oracle/oradata/STANDBY/datafile'
*.log_file_name_convert='/u01/app/oracle/oradata/PRIMARY/datafile','/u01/app/oracle/oradata/STANDBY/datafile','/u01/app/oracle/flash_recovery_area/PRIMARY/onlinelog','/u01/app/oracle/flash_recovery_area/STANDBY/onlinelog'
EOF
--
sql> startup nomount force pfile='/home/oracle/pfile';
sql> create spfile from pfile='/home/oracle/pfile';
sql> alter database mount standby database;
rman> catalog start with '/backuppiece';
rman> restore database;
rman> recover database;
rman> recover database until scn xxx;
sql> alter database recover managed standby database disconnect from session;
sql> alter database recover managed standby database cancel;
sql> alter database open read only; ???
sql> alter database recover managed standby database disconnect from session;


-- standby_file_management 没设置导致 ORA-01111 ORA-01110 ORA-01157 ORA-01111 ORA-01110
-- http://www.dba-oracle.com/t_data_guard_physical_standby_missing_file_tips.htm
1. 调整 db_file_name_convert  和 standby_file_management 
2. At the standby : alter system set standby_file_management=manual;
3. Primary 
sql> alter tablespace <tablespace name> begin backup ;
sh> scp datafile to standby:./
sql> alter tablespace <tablespace name> end backup; 
4. standby
At the Standby:

SQL> alter database rename file '.......UNNAMED00167' to '< actual location of the datafile >';
sql> alter database create datafile '/u01/app/oracle/oradata/TEST/datafile/o1_mf_tbs_1_h2hsng6v_.dbf' as new;



-- ADG 同步情况
alter session set nls_date_format='yyyy-mm-dd_hh24:mi:ss';
col NAME format a80
select * from ( select distinct name,next_time,completion_time,applied,thread#,SEQUENCE# from v$archived_log order by next_time desc ) where rownum < 15 ;


-- Check ADG status of sync to standby https://community.oracle.com/thread/2228773
select thread#, max(sequence#) from v$log_history group by thread# order by thread#;

   THREAD#                          MAX(SEQUENCE#)
---------- ---------------------------------------
         1                                   19413
         2                                   21242




-- on slave, lags
select * from V$DATAGUARD_STATS;

-- on standby, check gaps:
SYS@STANDBY> select * from v$archive_gap;

   

-- master adg ckecking
select distinct instance_name,db_unique_name,protection_mode,database_role,open_mode,status,switchover_status from gv$instance,gv$database;
--
INSTANCE_NAME    DB_UNIQUE_NAME                 DATABASE_ROLE    OPEN_MODE            STATUS       SWITCHOVER_STATUS
---------------- ------------------------------ ---------------- -------------------- ------------ --------------------
ADG              ADG                            SNAPSHOT STANDBY MOUNTED              MOUNTED      NOT ALLOWED

-- regesiter archivelog file to database;
alter database register physical logfile '/tmp/archivelogfile.dbf';
-- apply it
alter database recover automatic standby database;

--
select SEQUENCE#,FIRST_TIME,NEXT_TIME ,APPLIED from v$archived_log order by 1;

-- error archive log
select distinct  destination, error from v$archive_dest;


-- Protection Mode
select protection_mode, protection_level from v$database;

-- Maximum Availability.
ALTER SYSTEM SET LOG_ARCHIVE_DEST_2='SERVICE=db11g_stby AFFIRM SYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=DB11G_STBY';
alter database set standby database to maximize availability;

-- Maximum Performance.
ALTER SYSTEM SET LOG_ARCHIVE_DEST_2='SERVICE=db11g_stby NOAFFIRM ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=DB11G_STBY';
alter database set standby database to maximize performance;

-- Maximum Protection.
ALTER SYSTEM SET LOG_ARCHIVE_DEST_2='SERVICE=db11g_stby AFFIRM SYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=DB11G_STBY';
shutdown immediate;
startup mount;
alter database set standby database to maximize protection;


-- Switchover manual
--
--primary , 先做，完成后再做standby节点
alter database commit to switchover to standby;
shutdown immediate;
startup nomount;
alter database mount standby database;
--
alter database recover managed standby database disconnect from session;
alter database open;
-- standby, 后做， 待primary切换后再进行
alter database commit to switchover to primary;
shutdown immediate;
startup;


-- failover manual
alter database flashback on ;
select flashback_on from v$database;
alter database recover managed standby database cancel;
alter database recover managed standby database finish;
alter database activate standby database;
alter database open;
-- reinstate manual
select to_char(standby_became_primary_scn) from v$database;
shutdown immediate
startup mount
flashback database To scn 2569953;
alter database convert to physical standby;
alter database open
alter database recover managed standby database disconnect from session;


-- snapshot manual
alter database flashback on ;
alter database convert to snapshot standby;
alter database open;
-- convert to physical
shutdown immediate
startup mount
alter database convert to physical standby;


-- Read-Only Standby (10G) and Active Data Guard(11G)
-- 10G
-- To switch the standby database into read-only mode, do the following.
shutdown immediate;
startup mount;
alter database open read only;
-- To resume managed recovery, do the following.
shutdown immediate;
startup mount;
alter database recover managed standby database disconnect from session;

-- 11G
shutdown immediate;
startup mount;
alter database open read only;
alter database recover managed standby database disconnect from session;


-- Snapshot Standby
shutdown immediate;
startup mount;      -- flashback_on: no
alter database recover managed standby database cancel;
alter database convert to snapshot standby;  
alter database open; -- flashback_on: restore point only



-- dg broker settup
-- https://oracle-base.com/articles/11g/data-guard-setup-using-broker-11gr2#switchover
-- broker配置需放置shared storage中，以便RAC能顺利读取配置。
alter system set dg_broker_config_file1='+DATA/oradb/datafile/dr1oradb.dat'  scope=spfile sid='*';
alter system set dg_broker_config_file2='+DATA/oradb/datafile/dr2oradb.dat'  scope=spfile sid='*';
-- 在primary和standby中启动
alter system set dg_broker_start=TRUE scope=spfile sid='*';
-- 在primary和standby中添加listener
-- 注意GLOBAL_DBNAME为<DB_UNIQUE_NAME>_DGMGRL.<DB_DOMAIN>
--
SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
     (ORACLE_HOME = /u01/app/oracle/product/11.2.0/db_1 )
     (SID_NAME = orsid1 )
     (GLOBAL_DBNAME=oradb )
    )
    (SID_DESC =
      (GLOBAL_DBNAME = oradb_DGMGRL)
      (ORACLE_HOME = /u01/app/oracle/product/11.2.0/db_1)
      (SID_NAME = orsid1)
      (SERVICE_NAME = oradb)
    )
  )
--
SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
     (ORACLE_HOME = /u01/app/oracle/product/11.2.0/dbhome_1)
     (SID_NAME = ADG)
     (GLOBAL_DBNAME=ADG)
    )
    (SID_DESC =
     (ORACLE_HOME = /u01/app/oracle/product/11.2.0/dbhome_1)
     (SID_NAME = ADG)
     (GLOBAL_DBNAME=ADG_DGMGRL )
     (SERVICE_NAME=ADG )
    )
 )
-- 在primary中添加dgmgrl的配置
DGMGRL> connect sys/oracle
DGMGRL> CREATE CONFIGURATION 'oradb_config' as PRIMARY DATABASE IS 'oradb' connect identifier is 'oradb' ;
DGMGRL> add database 'ADG' AS CONNECT IDENTIFIER IS 'ADG' MAINTAINED AS PHYSICAL;   
DGMGRL> enable configuration
--
DGMGRL> connect sys/oracle
DGMGRL> disable configuration;
DGMGRL> REMOVE CONFIGURATION;
dgmgrl> create configuration ORADB_CONFIG as primary database is PRIDB connect identifier is PRIDB ;
dgmgrl> add database STBDB as connect identifier is STBDB maintained as physical;   
dgmgrl> enable configuration
--
DGMGRL> show configuration;
DGMGRL> show database 'ADG';

-- switchover
DGMGRL> SWITCHOVER TO 'ADG';
-- switch back
DGMGRL> SWITCHOVER TO 'ORCL';

-- failover 注意primary要启用flashback, 否则要重做standby
oracle@ADG $ dgmgrl sys/oracle@ADG
DGMGRL> FAILOVER TO 'ADG';
DGMGRL> REINSTATE DATABASE 'ORCL';

-- Snapshot Standby
$ dgmgrl sys/oracle@ORCL
DGMGRL> CONVERT DATABASE 'ADG' TO SNAPSHOT STANDBY;
DGMGRL> CONVERT DATABASE 'ADG' TO PHYSICAL STANDBY;


-- ------------------------------
-- RAC
-- ------------------------------

-- rac command  (https://www.oracle-scripts.net/useful-oracle-rac-commands/)
-- RAC  Real Application Clusters
-- CRSCTL Oracle Clusterware Control Utility
-- SRVCTL
-- ASM Automatic Storage Management 
-- ONL  Oracle Net listeners
-- GSD Global Service Daemon
-- ONS Oracle Notification Service


-- To know the cluster name: 
olsnodes -c

-- How to check the current status of CRS?
crsctl check crs
CRS-4638: Oracle High Availability Services is online (has)
CRS-4537: Cluster Ready Services is online (crs)
CRS-4529: Cluster Synchronization Services is online (css)
CRS-4533: Event Manager is online


-- How to To start and stop oracle clusterware (CRS)?
crsctl stop crs
crsctl stop crs -f 
crsctl start crs
crsctl start res ora.cluster_interconnect.haip -init


-- How to display the current configuration of the SCAN VIPs?
srvctl config scan
--report
SCAN name: rac-scan, Network: 1/10.255.255.0/255.255.255.0/eth1
SCAN VIP name: scan1, IP: /rac-scan/10.255.255.25

-- How to display the status of SCAN VIPs and SCAN listeners?
srvctl status scan
SCAN VIP scan1 is enabled
SCAN VIP scan1 is running on node rac1


-- If you want to add or modify a scan VIP: 
srvctl add | modify scan -n my-scan
-- To delete it: 
srvctl remove scan

-- How to display the status of SCAN listeners?
srvctl status scan_listener
SCAN Listener LISTENER_SCAN1 is enabled
SCAN listener LISTENER_SCAN1 is running on node rac1



-- change Listeners
alter system set remote_listener='(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=pri-scan)(PORT=1522))))' sid='*'; 
-- change listener on RAC
-- check
srvctl config scan_listener
-- config
srvctl modify scan_listener -p TCP:1522
-- restart and enable it
srvctl stop scan_listener
srvctl start scan_listener


-- 实际操作
-- kill session
BEGIN
  FOR r IN (select sid,serial# from v$session where username='user')
  LOOP
      EXECUTE IMMEDIATE 'alter system kill session ''' || r.sid  || ','
        || r.serial# || ''' immediate';
  END LOOP;
END;
/

-- 检查 在scanip上操作（两个操作也可以）：
grid ~:$ srvctl config scan_listener
-- 调整
grid ~ :$ srvctl modify scan_listener -p TCP:1522
-- 重启
grid ~:$ srvctl stop scan_listener
grid ~:$ srvctl start scan_listener
-- 验证
grid ~:$ ss -nltp | grep 152
SQL> show parameter remote
-- 注册
show parameter remote_listener
alter system set remote_listener='(DESCRIPTION =(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=172.16.70.35) (PORT=1522))))' sid='*';
show parameter remote_listener



-- How to verify the integrity of OCR?
cluvfy comp ocr -n all -verbose
--resport:
Verifying OCR integrity 
Checking OCR integrity...
Checking the absence of a non-clustered configuration...
All nodes free of non-clustered, local-only configurations
ASM Running check passed. ASM is running on all specified nodes
Checking OCR config file "/etc/oracle/ocr.loc"...
OCR config file "/etc/oracle/ocr.loc" check successful
Disk group for ocr location "+DATA" available on all the nodes
NOTE: 
This check does not verify the integrity of the OCR contents. Execute 'ocrcheck' as a privileged user to verify the contents of OCR.
OCR integrity check passed
Verification of OCR integrity was successful. 
--
cat /etc/oracle/ocr.loc
ocrconfig_loc=+DATA
local_only=FALSE
--
ASMCMD> ls -l +DATA/rac-cluster/OCRFILE/REGISTRY.255.995375047
Type     Redund  Striped  Time             Sys  Name
OCRFILE  UNPROT  COARSE   JUL 01 09:00:00  Y    REGISTRY.255.995375047


--How to backup the OCR?
--Oracle takes physical backup of OCR automatically every 3 hours. Default location is CRS_home/cdata/my_cluster_name/OCRBackup.
--The ocrconfig tool is used to make daily copies of the automatically generated backup files.

--Show OCR backups:
ocrconfig -showbackup
--report:
rac2     2019/07/01 07:00:57     /u01/app/11.2.0/grid/cdata/rac-cluster/backup00.ocr
rac2     2019/07/01 03:00:22     /u01/app/11.2.0/grid/cdata/rac-cluster/backup01.ocr
rac2     2019/06/30 23:00:11     /u01/app/11.2.0/grid/cdata/rac-cluster/backup02.ocr
rac2     2019/06/30 02:59:46     /u01/app/11.2.0/grid/cdata/rac-cluster/day.ocr
rac1     2019/06/24 13:30:56     /u01/app/11.2.0/grid/cdata/rac-cluster/week.ocr
PROT-25: Manual backups for the Oracle Cluster Registry are not available



-- orc voting change 
sudo /u01/app/11.2.0/grid/bin/ocrconfig -add +OCR2
crsctl replace votedisk +OCR2
sudo /u01/app/11.2.0/grid/bin/ocrconfig -delete +OCR


-- How to inspect the database configuration?
srvctl config database -d oradb
--report:
Database unique name: oradb
Database name: oradb
Oracle home: /u01/app/oracle/product/11.2.0/db_1
Oracle user: oracle
Spfile: +DATA/oradb/spfileorsid.ora
Domain: 
Start options: open
Stop options: immediate
Database role: PRIMARY
Management policy: AUTOMATIC
Server pools: oradb
Database instances: orsid1,orsid2
Disk Groups: DATA
Mount point paths: 
Services: 
Type: RAC
Database is administrator managed

--How to display the name and the status of the instances in the RAC?
srvctl status database -d oradb
--report
Instance orsid1 is running on node rac1
Instance orsid2 is running on node rac2

-- To list just active nodes: 
olsnodes -s -t
--report:
rac1    Active  Unpinned
rac2    Active  Unpinned


-- ologgerd process high cpu load
-- it can be stopped by executing on both nodes:
crsctl stop resource ora.crf -init
-- to disable ologgerd permanently, execute:
crsctl delete resource ora.crf -init

-- how to start|stop the database?
srvctl stop database -d my-db-name -o immediate
srvctl start database -d my-db-name

-- How to start|stop one instance of the RAC?
srvctl start instance -d my-db-name -i my-db-name1
srvctl stop instance -d my-db-name -i my-db-name1 
srvctl stop instance -d my-db-name -i my-db-name1 -force
-- Use -force if the instance to stop is not on the local server

-- How to start and stop a PDB in Oracle RAC?
-- ???
--Stop a PDB
--On the current node [or on all the nodes]:
ALTER PLUGGABLE DATABASE my-PDB-name CLOSE IMMEDIATE [Instances=all];
--This will stop the associated service too.
--Manually stopping the associated service will not close the PDB. You have to use this SQL command.
--Start a PDB
--On the current node [or on all the nodes]:
ALTER PLUGGABLE DATABASE my-PDB-name OPEN [Instances=all;]
--You can also start the PDB with the associated service
--This will NOT start the service(s) associated with this PDB.

--How to stop and start a Listener?
srvctl stop listener -l LISTENER_NAME
srvctl start listener -l LISTENER_NAME




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



-- table modified
select * from DBA_TAB_MODIFICATIONS;


-- database state performance 
select event, state, count(*) from v$session_wait group by event, state order by 3 desc

EVENT						   STATE		       COUNT(*)
-------------------------------------------------- ------------------------- ----------
SQL*Net message from client			   WAITING			    379
rdbms ipc message				   WAITING			     50
class slave wait				   WAITING			     12
gcs remote message				   WAITING			      4
LNS ASYNC end of log				   WAITING			      2


-- connected session;
SELECT SID, SERIAL#, MACHINE FROM gv$SESSION;

-- check session and process, get PID
select s.sid, s.serial#, p.spid processid, s.process clientpid from gv$process p, gv$session s where p.addr = s.paddr ;


-- count process.
select count(*) from gv$process;
select value from v$parameter where name ='processes' ;


-- show evnets wait
SELECT wait_class#,wait_class_id,wait_class,COUNT(1) AS "count"
FROM gv$event_name
GROUP BY wait_class#, wait_class_id, wait_class ORDER BY 4 desc
/
--
WAIT_CLASS# WAIT_CLASS_ID WAIT_CLASS             count
----------- ------------- -----------------------
          0    1893977003 Other                   1916
          6    2723168908 Idle                     192
          3    4166625743 Administrative           110
         11    3871361733 Cluster                  100
          8    1740759767 User I/O                  96
          7    2000153315 Network                   70
          4    3875070507 Concurrency               66
          9    4108307767 System I/O                64
          2    3290255840 Configuration             48
          1    4217450380 Application               34
         12     644977587 Queueing                  18
         10    2396326234 Scheduler                 16
          5    3386400367 Commit                     4


-- wait_class
select wait_class, sum(time_waited), sum(time_waited)/sum(total_waits) Sum_Waits From gv$system_wait_class Group by wait_class Order by 3 desc;
--
WAIT_CLASS                               SUM(TIME_WAITED)  SUM_WAITS
---------------------------------------- ---------------- ----------
Idle                                            285769886 59.4932023
Scheduler                                            3285 4.80263158
Commit                                               1108 3.14772727
Configuration                                          23 .638888889
Network                                             24623  .38554764
User I/O                                            28608 .378347639
Cluster                                              7022 .160642387
System I/O                                          48519 .124515286
Concurrency                                         21799 .024855081
Application                                           173 .018716867
Other                                              126192 .016133969




-- 查看最近消耗最多资源的语句
-- top SQL statements that are currently stored in the SQL cache ordered by elapsed time

set linesize 180
col sql_fulltext format a25
col sql_id format a25
col FIRST_LOAD_TIME format a25
col LAST_LOAD_TIME format a25
SELECT * FROM
(SELECT sql_fulltext, sql_id, elapsed_time, child_number, disk_reads, executions, first_load_time, last_load_time FROM gv$sql ORDER BY elapsed_time DESC) WHERE ROWNUM < 10 ; 

--
SQL_FULLTEXT		       SQL_ID	       ELAPSED_TIME CHILD_NUMBER DISK_READS EXECUTIONS FIRST_LOAD_TIME		 LAST_LOAD_TIME
------------------------------ --------------- ------------ ------------ ---------- ---------- ------------------------- -------------------------
BEGIN SP_ST_FEEDER_CTN_QRY(:1, 59q2zvpf2cuzz	 1637055902	       0    2060894	    27 2018-09-29/09:36:05	 2018-09-29/09:36:05
SELECT COUNT(1) FROM (SELECT S 82y10vp2p6ww3	  443434457	       0     367953	     1 2018-09-29/10:34:39	 2018-09-29/10:34:39
DECLARE job BINARY_INTEGER :=  6gvch1xu9ca3g	  342201758	       0     649290	  2576 2018-09-24/23:18:10	 2018-09-27/15:47:18


-- top 10 statements by disk read
select * from ( select sql_id,child_number from v$sql order by disk_reads desc) where rownum<11 ;


--
-- actual plan from the SQL cache and the full text of the SQL.
SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR( &sql_id, &child ));


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


select path,failgroup,mount_status,mode_status,header_status,state from v$asm_disk order by failgroup, path;

PATH                                     FAILGROUP                      MOUNT_S MODE_ST HEADER_STATU STATE
---------------------------------------- ------------------------------ ------- ------- ------------ --------
ORCL:DATA                                DATA                           CACHED  ONLINE  MEMBER       NORMAL
ORCL:FRA                                 FRA                            CACHED  ONLINE  MEMBER       NORMAL
ORCL:ORC1                                ORC1                           CACHED  ONLINE  MEMBER       NORMAL
ORCL:ORC2                                ORC2                           CACHED  ONLINE  MEMBER       NORMAL
ORCL:ORC3                                ORC3                           CACHED  ONLINE  MEMBER       NORMAL
ORCL:NEWDATA                                                            CLOSED  ONLINE  PROVISIONED  NORMAL
ORCL:NEWFRA                                                             CLOSED  ONLINE  PROVISIONED  NORMAL
ORCL:NEWOCR1                                                            CLOSED  ONLINE  PROVISIONED  NORMAL
ORCL:NEWOCR2                                                            CLOSED  ONLINE  PROVISIONED  NORMAL
ORCL:NEWOCR3                                                            CLOSED  ONLINE  PROVISIONED  NORMAL



-- asm group info
col name format a20;
select name,total_mb,total_mb-free_mb used_mb,free_mb,round((total_mb-free_mb)/total_mb,3)*100 "used_rate(%)" from v$asm_diskgroup;

NAME		       TOTAL_MB    USED_MB    FREE_MB used_rate(%)
-------------------- ---------- ---------- ---------- ------------
ARCDG1			1023986     420989     602997	      41.1
DATADG1 		2559965     645474    1914491	      25.2
OCR			   3069        926	 2143	      30.2

-- asm create vg
SQL> select path,header_status,state,os_mb from v$asm_disk;

PATH                 HEADER_STATU      STATE              OS_MB
-------------------- ------------ -------- ----------     ---------------------------
ORCL:DISK5           FORMER              NORMAL         4094
ORCL:DISK1           FORMER              NORMAL         4094
ORCL:DISK2           FORMER              NORMAL         4094
ORCL:DISK10         PROVISIONED  NORMAL         4094
ORCL:DISK4           FORMER              NORMAL         4094


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

-- 如果 db_create_file_dest 有设置，例如"+DATA"的时候，使用以下方式添加数据文件
alter tablespace USERS add datafile '+DATA' size 5G AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;
-- alter system set db_create_file_dest='/u01/app/oracle/oradata';
alter tablespace USERS add datafile size 5G AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;



-- alter datafile
ALTER DATABASE DATAFILE '/u02/oracle/rbdb1/users03.dbf' AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;



-- show all datafile space , 计算所有数据大小
select round(sum(user_bytes)/(1024*1024*1024),2) "TotalSpace GB" from dba_data_files;


-- show specific datafile and info
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
ALTER USER user_name DEFAULT TABLESPACE USERS;
ALTER USER user_name TEMPORARY TABLESPACE TEMP;

--  Temporary Tablespace Usage
select round(100*(  free_space / Tablespace_size) ,0) free_perc  from dba_temp_free_space;
SELECT * FROM   dba_temp_free_space ;
 
SELECT 
   A.tablespace_name tablespace, D.mb_total,
   SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_used, D.mb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_free
FROM 
   v$sort_segment A,
    (
    SELECT B.name, C.block_size, SUM (C.bytes) / 1024 / 1024 mb_total
    FROM v$tablespace B, v$tempfile C
    WHERE B.ts#= C.ts# 
    GROUP BY B.name, C.block_size) D
WHERE A.tablespace_name = D.name 
GROUP by A.tablespace_name, D.mb_total
/


-- tempfile

-- move tempfile
STARTUP MOUNT
SELECT name FROM v$tempfile;
ALTER DATABASE RENAME FILE  '/u01/app/oracle/oradata/EE/temp01.dbf' to '/u01/app/oracle/oradata/new/temp01.dbf';
SELECT name FROM v$tempfile;
ALTER DATABASE OPEN;

-- drop tempfile
ALTER DATABASE TEMPFILE '/u01/app/oracle/oradata/EE/temp01.dbf' DROP INCLUDING DATAFILES;
-- kill session and drop tempfile
--ORA-25152: TEMPFILE cannot be dropped at this time
SELECT s.sid, s.username, s.status, u.tablespace, u.segfile#, u.contents, u.extents, u.blocks FROM v$session s, v$sort_usage u WHERE s.saddr=u.session_addr ORDER BY u.tablespace, u.segfile#, u.segblk#, u.blocks;
--
       SID USERNAME			  STATUS   TABLESPACE			     SEGFILE# CONTENTS	   EXTENTS     BLOCKS
---------- ------------------------------ -------- ------------------------------- ---------- --------- ---------- ----------
       317 CKSES			  INACTIVE TMP					  207 TEMPORARY 	 1	  128

select sid,serial# from v$session where sid = 317 ;
alter system kill session '758,771';




-- 数据泵 impdp expdb
--example
expdp cksp/NEWPASSWORD directory=expdir dumpfile=cksp83.dmp schemas=cksp exclude=TABLE:\"LIKE \'TMP%\'\"  logfile=expdp83.log parallel=2 job_name=expdpjob compression=all exclude=statistics 
--example
expdp cksp/cksp4631 directory=DUMP_4631 dumpfile=cksp83.dmp schemas=cksp exclude=TABLE:\"LIKE \'TMP%\'\"  logfile=expdp83_1.log parallel=2 job_name=expdpjob_1 
--example
expdp system/oracle directory=data_pump_dir dumpfile=scott.dmp schemas=scott logfile=expdp_scott.log parallel=2 job_name=expdp_scott.job
expdp cks/NEWPASSWORD DUMPFILE=cd2tables.dmp DIRECTORY=data_pump_dir TABLES=CD_FACILITY,CD_PORT
impdp system/NEWPASSWORD dumpfile=cksp.dmp directory=DATA_PUMP_DIR logfile=cksp_imp.log schemas=cksp table_exists_action=replace remap_schema=cksp:cksp
--example
expdp sys/oracle \"/ as sysdba\"  schemas=ckspub01 directory=CKSDATA exclude=TABLE:\"LIKE \'TMP%\'\" exclude=TABLE:\"LIKE \'VT%\'\" job_name=expdp20191216 logfile=expdp20191216.log dumpfile=expdp20191216.dmp
-- import from network
drop user cksp cascade;
impdp  \"/ as sysdba\" network_link=tmtest_dblink schemas=user job_name=impdp1`date +"%Y%m%d"` directory=DATA_PUMP_DIR logfile=impdp_`date +"%Y%m%d"`.log
-- dump table
expdp \"/ as sysdba\" tables=scott.t1 dumpfile=t1.`date +%F`.dump logfile=t1.`date +%F`.dump.log directory=DUMP_FILE_DIR
expdp \"/ as sysdba\" tables=schema.table1,schema.table2 dumpfile=passengercheckinrecord.`date +%F`.dump logfile=passengercheckinrecord.`date +%F`.dump.log directory=dpdump
impdp \"/ as sysdba\" dumpfile=SYS_ENTITY_OPERATE_LOG.2020-04-24.dump directory=CKSDATA
-- impdp sys用户不需要指定schema，因为expdp时候已经带有。但没有进行table_exists测试

impdp \"/ as sysdba\" network_link=TNS_DBLINK schemas=SCHEMA directory=DATA_PUMP_DIR logfile=SCHEMA.impdp.`date +%F`.dump.log table_exists_action=replace remap_schema=SCHEMA:SCHEMA EXCLUDE=STATISTICS
impdp \"/ as sysdba\" schemas=SCHEMA directory=DATA_PUMP_DIR logfile=SCHEMA.impdp.`date +%F`.log dumpfile=SCHEMA.dump table_exists_action=replace remap_schema=SCHEMA:SCHEMA EXCLUDE=STATISTICS
expdp \"/ as sysdba\" schemas=SCHEMA directory=DATA_PUMP_DIR logfile=SCHEMA.expdp.`date +%F`.log ESTIMATE_ONLY=yes 
expdp \"/ as sysdba\" schemas=SCHEMA directory=DATA_PUMP_DIR logfile=SCHEMA.expdp.`date +%F`.log dumpfile=SCHEMA.`date +%F`.dump compression=all


-- check space
select sum(bytes)/1024/1024 mb , tablespace_name  from user_segments group by tablespace_name;

-- kill job
-- if not exit the prompt
Export >
kill_job
-- if exit the promt, get the jobname name attach on it
select * from dba_datapump_jobs;
impdp username/password@database attach=name_of_the_job   --(Get the name_of_the_job using the above query)
Import>kill_job

-- 
exec utl_recomp.recomp_serial('CKSP');



-- ------------------------------
-- tablespace
-- ------------------------------
-- rename or moving oracle files
alter tablespace users offline normal ; 
! mkdir -p /u01/app/oracle/datafiles/ORADB/
! mv '/u01/app/oracle/oradata/ORADB/user01.dbf' '/u01/app/oracle/datafiles/ORADB/user01.dbf'
ALTER TABLESPACE users RENAME DATAFILE '/u01/app/oracle/oradata/ORADB/user01.dbf' TO '/u01/app/oracle/datafiles/ORADB/user01.dbf';
alter tablespace users online ; 

--start mount;
!mv /u01/app/oracle/oradata/ORADB/sys.dbf /u01/app/oracle/datafiles/ORADB/sys.dbf
ALTER DATABASE RENAME FILE '/u01/app/oracle/oradata/ORADB/sys.dbf' TO '/u01/app/oracle/datafiles/ORADB/sys.dbf'; 
ALTER DATABASE RENAME FILE '/u01/app/oracle/oradata/ORADB/sysaux.dbf' TO '/u01/app/oracle/datafiles/ORADB/sysaux.dbf';


--rename table
ALTER TABLE test1 ADD ( CONSTRAINT test1_pk PRIMARY KEY (col1));
ALTER TABLE test1 RENAME TO test;
ALTER TABLE test RENAME COLUMN col1 TO id;
ALTER TABLE test RENAME COLUMN col2 TO description;
ALTER TABLE test RENAME CONSTRAINT test1_pk TO test_pk;
ALTER INDEX test1_pk RENAME TO test_pk;


--
SELECT 'alter table T1 rename constraint ' ||  CONSTRAINT_NAME || ' to ' ||  CONSTRAINT_NAME || '_bak;'
FROM user_constraints 
WHERE 
table_name = 'T1';

SELECT 'alter index ' ||  INDEX_NAME || ' rename to ' ||  INDEX_NAME || '_bak;'
FROM user_indexes
WHERE 
table_name = 'T1';

SELECT 'alter tigger ' ||  TRIGGER_NAME || ' rename to ' ||  TRIGGER_NAME || '_bak;'
FROM user_triggers
WHERE 
table_name = 'T1';



-- clear redo logfile
ALTER DATABASE CLEAR LOGFILE GROUP 3;

-- redo log create/add group
ALTER DATABASE ADD LOGFILE thead 2 GROUP 3 ('/oracle/dbs/log1c.rdo', '/oracle/dbs/log2c.rdo') SIZE 100M BLOCKSIZE 512;
-- redo log delete group
ALTER DATABASE DROP LOGFILE GROUP 3;

-- redo log add member
ALTER DATABASE ADD LOGFILE MEMBER '/u01/app/oracle/oradata/EE/redo01.log' TO GROUP 1;
-- redo log delete member
ALTER DATABASE DROP LOGFILE MEMBER '/oracle/dbs/log3c.rdo';

-- adg management is automatic.
alter database add standby logfile;


-- Multiplexed redolog recover

select * from v$logfile where status = 'INVALID'; 
--
    GROUP# STATUS  TYPE    MEMBER                                                                 IS_
---------- ------- ------- ---------------------------------------------------------------------- ---
         1 INVALID ONLINE  /u01/app/oracle/oradata/EE/redo01.log                                  NO

ALTER DATABASE DROP LOGFILE MEMBER '/u01/app/oracle/oradata/EE/redo01.log';
ALTER DATABASE ADD LOGFILE MEMBER '/u01/app/oracle/oradata/EE/redo01.log' TO GROUP 1;
alter system switch logfile;



-- remove logfile / file 1 needs more recovery to be consistent

from most difficult to least difficult, follows:
1 The current online redo log
2 An active online redo log
3 An unarchived online redo log
4 An inactive online redo log
5 recover database using backup controlfile until cancel;


-- Status  Description
UNUSED: The online redo log has never been written to.
CURRENT: The online redo log is active, that is, needed for instance recovery, and it is the log to which the database is currently writing. The redo log can be open or closed.
ACTIVE: The online redo log is active, that is, needed for instance recovery, but is not the log to which the database is currently writing.It may be in use for block recovery, and may or may not be archived.
CLEARING: The log is being re-created as an empty log after an ALTER DATABASE CLEAR LOGFILE statement. After the log is cleared, then the status changes to UNUSED.
CLEARING_CURRENT: The current log is being cleared of a closed thread. The log can stay in this status if there is some failure in the switch such as an I/O error writing the new log header.
INACTIVE: The log is no longer needed for instance recovery. It may be in use for media recovery, and may or may not be archived.

-- https://docs.oracle.com/cd/B10501_01/server.920/a96572/recoscenarios.htm
-- Clearing Inactive, Archived Redo
alter database mount
alter database clear logfile group 2;

-- Clearing Inactive, Not-Yet-Archived Redo
-- 首先备份  否则执行 clean logfile 会删除 redolog的内容
! cp /disk1/oracle/dbs/log  /disk2/backup
ALTER DATABASE BACKUP CONTROLFILE TO '/oracle/dbs/cf_backup.f';
alter database clear unarchived logfile group 2;
recover using backup controlfile until cancel;
alter database open resetlogs ; 





Specify log: {<RET>=suggested | filename | AUTO | CANCEL}
AUTO
--
alter database open resetlogs;
shutdown immediate
startup mount
-- 由于undo和redo的异常，需要设置参数 _allow_resetlogs_corruption, 并且手动处理undo

-- check undo
select sum(a.bytes) as undo_size from v$datafile a, v$tablespace b, dba_tablespaces c where c.contents = 'UNDO' and c.status = 'ONLINE' and b.name = c.tablespace_name and a.ts# = b.ts#;

-- rebuild undo
ALTER SYSTEM SET "_allow_resetlogs_corruption"= TRUE SCOPE = SPFILE;
ALTER SYSTEM SET undo_management=MANUAL SCOPE = SPFILE;
shutdown immediate
startup mount
alter database open resetlogs;
CREATE UNDO TABLESPACE undo2 datafile '/u01/app/oracle/oradata/RTS_NEW/undo2_df1.dbf' size 200m autoextend on;
alter system set undo_tablespace = undo2 scope=spfile;
alter system set undo_management=auto scope=spfile;
shutdown immediate
startup


-- 这里应该是没有做undo处理的异常, 应该是undo和redo/ system的一致性问题

SYS@EE> insert into t1 select * from t1 ; 
insert into t1 select * from t1
            *
ERROR at line 1:
ORA-01552: cannot use system rollback segment for non-system tablespace 'USERS'


SYS@EE> select segment_name, status from dba_rollback_segs;

SEGMENT_NAME                   STATUS
------------------------------ ----------------
SYSTEM                         ONLINE
_SYSSMU10_3550978943$          OFFLINE
_SYSSMU9_1424341975$           OFFLINE
_SYSSMU8_2012382730$           OFFLINE
_SYSSMU7_3286610060$           OFFLINE
_SYSSMU6_2443381498$           OFFLINE
_SYSSMU5_1527469038$           OFFLINE
_SYSSMU4_1152005954$           OFFLINE
_SYSSMU3_2097677531$           OFFLINE
_SYSSMU2_2232571081$           OFFLINE
_SYSSMU1_3780397527$           OFFLINE

-- 解决方法：http://dbarohit.blogspot.com/2013/08/ora-01552-cannot-use-system-rollback.html
alter system set "_system_trig_enabled" = FALSE;
alter trigger sys.cdc_alter_ctable_before DISABLE;
alter trigger sys.cdc_create_ctable_after DISABLE;
alter trigger sys.cdc_create_ctable_before DISABLE;
alter trigger sys.cdc_drop_ctable_before DISABLE;
create undo tablespace UNDOTBS2 datafile '/u01/app/oracle/oradata/EE/undotbs02.dbf' size 200m;
alter system set undo_tablespace=UNDOTBS2 scope=spfile;
drop tablespace UNDOTBS1 including contents;
alter trigger sys.cdc_alter_ctable_before ENABLE;
alter trigger sys.cdc_create_ctable_after ENABLE;
alter trigger sys.cdc_create_ctable_before ENABLE;
alter trigger sys.cdc_drop_ctable_before ENABLE;
alter system set "_system_trig_enabled" = TRUE;
alter system set undo_management=AUTO scope=spfile;
shutdown immediate ; 
startup 
show parameter undo
select name,status from v$datafile
 where name like '%undo%';


-- undo 查询
select tablespace_name, status, count(*) from dba_rollback_segs group by tablespace_name, status;
create undo tablespace UNDOTBS1 datafile '/u01/app/oracle/oradata/EE/undotbs01.dbf' size 200m AUTOEXTEND on MAXSIZE UNLIMITED;
DROP TABLESPACE undotbs1 INCLUDING CONTENTS AND DATAFILES ;



-- check datafile is online or not
col name format a50
select file#, name, status, to_char(checkpoint_change#),resetlogs_change#, recover, fuzzy from v$datafile_header;



-- 默认新建datafiles文件位置
*.db_create_file_dest='/u01/app/oracle/oradata';


-- create tablespace
CREATE TABLESPACE test datafile 'test01.dbf' SIZE 40M AUTOEXTEND ON;
CREATE TABLESPACE tablespacename DATAFILE '/ORADATA/tablespacename01.dbf' SIZE 5G AUTOEXTEND ON NEXT 5G AUTOEXTEND ON MAXSIZE UNLIMITED;
ALTER TABLESPACE ticket_tablespaces ADD DATAFILE '+DATA' size 5G AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;


-- create test table
create table test_table tablespace TEST as select * from dba_data_files ; 


-- drop table
DROP TABLE brands;
--ORA-02449: unique/primary keys in table referenced by foreign keys
DROP TABLE brands CASCADE CONSTRAINTS;


-- drop tablespaces
DROP TABLESPACE tbs_01 INCLUDING CONTENTS CASCADE CONSTRAINTS; 
DROP TABLESPACE tbs_02 INCLUDING CONTENTS AND DATAFILES;


-- tempfile
-- 注意，重启实例temporary的datafile会自动重建不会报警，但在线丢失或者异常会导致sort用不了，处理就如下：
create temporary tablespace TEMP2 tempfile '/u01/app/oracle/oradata/ORADB/temp02.dbf' size 100m autoextend on;
alter database default temporary tablespace TEMP2 ; 
-- check which session using old temp
SELECT USERNAME, SESSION_NUM, SESSION_ADDR FROM V$SORT_USAGE;
drop tablespace TEMP including contents and datafiles ; 
--
create temporary tablespace TEMP tempfile '+DATA/oradb/tempfile/temp01.dbf' size 100m autoextend on;
ALTER TABLESPACE TEMP ADD TEMPFILE '/u01/app/oracle/oradata/OLTP/temp01.dbf' SIZE 1024M REUSE AUTOEXTEND ON NEXT 50M  MAXSIZE unlimited;
--
alter database default temporary tablespace TEMP;




-- check procedure
SELECT * FROM ALL_OBJECTS WHERE OBJECT_TYPE IN ('FUNCTION','PROCEDURE','PACKAGE')
SELECT Text FROM User_Source;
select text from user_source where name='BATCHINPUTMEMBERINFO';
select distinct name from user_source where name like 'P_IMPORT_TICKETINFO_%'; 


-- 查询上述超过1分钟以上会话的SQL ID对应的SQL语句
select distinct piece,sql_text from gv$sqltext where sql_id='&sql_id' order by piece asc;

-- 查询到当时的传入参数
select name,position,datatype_string,value_string from dba_hist_sqlbind
where sql_id='&sqlid' order by snap_id,name,position;

-- 观察超过1分钟以上的holder会话 (holder不能被查询sql_id)
SELECT l.inst_id,DECODE(l.request,0,'Holder: ','Waiter: ')||l.sid sid ,s.serial#, s.machine, s.program,to_char(s.logon_time,'yyyy-mm-dd hh24:mi:ss'),l.id1, l.id2, l.lmode, l.request, l.type, s.sql_id,s.sql_child_number, s.prev_sql_id,s.prev_child_number
FROM gV$LOCK l , gv$session s 
 WHERE (l.id1, l.id2, l.type) IN (SELECT id1, id2, type FROM GV$LOCK WHERE request>0)
 and l.inst_id=s.inst_id and l.sid=s.sid
ORDER BY l.inst_id,l.id1, l.request
/

-- V$SESSION.SID and V$SESSION.SERIAL# are database process id
-- V$PROCESS.SPID – Shadow process id on the database server
-- V$SESSION.PROCESS – Client process id

-- get session, spid is OS process id.
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


-- check sql_text
select sql_fulltext from gv$sqlarea where sql_id='&sql_id';
select sid,serial#, user, machine from gv$session where sql_id='&sql_id' and status='ACTIV';
SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id',0));


-- kill session
select OSUSER,MACHINE,TERMINAL,PROCESS,program from gv$session where sid = &sid;
alter system kill session '&sid,&serial' immediate;
alter system kill session '&sid,&serial,@&inst_id' immediate;


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


-- kill all other session from machine
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

-- kill all other session from username
BEGIN
  FOR r IN (select sid,serial# from v$session where username='user')
  LOOP
      EXECUTE IMMEDIATE 'alter system kill session ''' || r.sid  || ',' 
        || r.serial# || ''' immediate';
  END LOOP;
END;





-- ------------------------------
-- objects
-- ------------------------------

-- 查询列对应的索引 indexes and columns
select * from user_ind_columns where table_name='PERSONALINFORMATION';
select * from user_indexes where table_name='PERSONALINFORMATION';
select distinct TABLE_NAME,TABLESPACE_NAME from user_indexes;


-- 查询columan
select COLUMN_NAME from all_tab_columns where TABLE_NAME='&table_name' ;

--  obtain information on index fields etc
col TABLE_OWNER format a10
col COLUMN_NAME format a25
col COLUMN_EXPRESSION format a15
SELECT
 i.table_owner,
 i.table_name,
 i.index_name,
 i.uniqueness,
 c.column_name,
 f.column_expression
FROM      all_indexes i
LEFT JOIN all_ind_columns c
 ON   i.index_name      = c.index_name
 AND  i.owner           = c.index_owner
LEFT JOIN all_ind_expressions f
 ON   c.index_owner     = f.index_owner
 AND  c.index_name      = f.index_name
 AND  c.table_owner     = f.table_owner
 AND  c.table_name      = f.table_name
 AND  c.column_position = f.column_position
WHERE i.table_owner = UPPER('&table_owner')
 AND  i.table_name  = UPPER('&table_name')
ORDER BY i.table_owner, i.table_name, i.index_name, c.column_position
/

TABLE_OWNE TABLE_NAME                     INDEX_NAME                     UNIQUENES COLUMN_NAME               COLUMN_EXPRESSI
---------- ------------------------------ ------------------------------ --------- ------------------------- ---------------
CKSP       TICKETRECORD_HIST              TICKET_HIST_INDE1              NONUNIQUE TICKETCODE                
CKSP       TICKETRECORD_HIST              TICKET_HIST_INDE2              NONUNIQUE TICKETTRANSACTION_ID      
CKSP       TICKETRECORD_HIST              TICKET_HIST_INDE3              NONUNIQUE SETOFFDATE                
CKSP       TICKETRECORD_HIST              TICKET_HIST_INDE4              NONUNIQUE INSERTTIME               




-- ------------------------------
-- INDEX
-- ------------------------------

-- 查询index是否失效；
select index_name, status, domidx_status, domidx_opstatus,funcidx_status from user_indexes where status<>'VALID' or funcidx_status<>'ENABLED' ;
alter index IDX_TR_RPT1 rebuild;


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

--drop index
drop index TICKETRECORD_PK; 



-- directory for datadump
select DIRECTORY_NAME, DIRECTORY_PATH from dba_directories;
create directory dump_file_dir as '/u01test';
create directory dump_file_dir as '/home/oracle/dump';
grant read,write on directory dump_file_dir to gabsj, hztb, xttb,mylcpt;
-- dba directory
SELECT * FROM SYS.DBA_DIRECTORIES;

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




-- ------------------------------
-- SQL TUNE
-- ------------------------------


-- Privilege
grant advisor to scott;
grant administer sql tuning set to scott;


-- innor join
select e.empno,e.ename,e.job,d.deptno,d.dname from emp e inner join dept d on e.deptno=d.deptno order by e.empno;
-- left join
select e.empno,e.ename,e.job,d.deptno,d.dname from emp e left join dept d on e.deptno=d.deptno order by e.empno;
-- right join
select e.empno,e.ename,e.job,d.deptno,d.dname from emp e right join dept d on e.deptno=d.deptno order by e.empno;
-- full join
select e.empno,e.ename,e.job,d.deptno,d.dname from emp e full join dept d on e.deptno=d.deptno order by e.empno;


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
SELECT TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS') "NOW" FROM DUAL;


--  显示gv$session超过60s的查询 queries currently running for more than 60 seconds
select s.username,s.sid,s.serial#, s.sql_id, round ( s.last_call_et/60, 2) mins_running from gv$session s where status='ACTIVE' and type <>'BACKGROUND' and last_call_et> 60 order  by mins_running desc ,sid,serial# ;

-- the average buffer gets per execution during a period of activity 
--
col username format a10;
col BUFFER_GETS format a10;
col BUFFER_GET_PER_EXEC format a10;
col PARSE_CALLS format a5;
col ROWS_PROCESSED format a5;
col ELAPSED_TIME format a15;
col USER_IO_WAIT_TIME format a15;
--
SELECT username, buffer_gets, disk_reads, executions, buffer_get_per_exec, parse_calls, sorts, rows_processed, hit_ratio, module, 
elapsed_time, cpu_time, user_io_wait_time, sql_id
FROM (SELECT b.username, a.disk_reads, a.buffer_gets, trunc(a.buffer_gets / a.executions) buffer_get_per_exec,
    a.parse_calls, a.sorts, a.executions, a.rows_processed, 100 - ROUND (100 * a.disk_reads / a.buffer_gets, 2) hit_ratio,
    module, a.sql_id, a.cpu_time, a.elapsed_time, a.user_io_wait_time FROM v$sqlarea a, dba_users b
    WHERE a.parsing_user_id = b.user_id AND b.username NOT IN ('SYS', 'SYSTEM', 'RMAN','SYSMAN')
    AND a.buffer_gets > 10000 ORDER BY buffer_get_per_exec DESC)
WHERE ROWNUM <= 20
/

--  SQL ordered by Elapsed Time in 20mins, like awr
col EXEs format 99999999;
col TOTAL_ELAPSED format 9999999999; 
col ELAPSED_PER_EXEC format 9999999999; 
col TOTAL_CPU format 9999999999; 
col CPU_PER_SEC format 9999999999; 
col TOTAL_USER_IO format 99999999.99; 
col USER_IO_PER_EXEC format 99999999.99; 
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

-- 超过20MBPGA的查询 The following query will find any sessions in an Oracle dedicated environment using over 20mb pga memory:
column pgA_ALLOC_MEM format 99,990
column PGA_USED_MEM format 99,990
column inst_id format 99
column username format a15
column program format a25
column logon_time format a25
column SPID format a15
select s.inst_id, s.sid, s.serial#, p.spid, s.machine, s.username, s.logon_time, s.program, PGA_USED_MEM/1024/1024 PGA_USED_MEM, PGA_ALLOC_MEM/1024/1024 PGA_ALLOC_MEM from gv$session s , gv$process p Where s.paddr = p.addr and s.inst_id = p.inst_id and PGA_USED_MEM/1024/1024 > 20 and s.username is not null order by PGA_USED_MEM;
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
-- 自定义pga数，例如输入20就是pga20M的查询

select s.inst_id, s.sql_id, s.sid, s.serial#, p.spid, s.machine, s.username, to_char(  s.logon_time, 'yyyy-mm-dd_hh24:mi:ss' ) logon_time, s.program, round(PGA_USED_MEM/1024/1024,0) PGA_USED_MEM, round(PGA_ALLOC_MEM/1024/1024,0) PGA_ALLOC_MEM from gv$session s , gv$process p Where s.paddr = p.addr and s.inst_id = p.inst_id and PGA_USED_MEM/1024/1024 > &mem_size and s.username is not null order by PGA_USED_MEM;



-- check sql_text
select sql_fulltext from gv$sqlarea where sql_id='&sql_id';
select sid,serial#, user, machine from gv$session where sql_id='&sql_id' and status='ACTIVE'; 
select s.sid, s.serial#, s.user, s.machine from gv$session s , gv$process p Where s.paddr = p.addr and s.inst_id = p.inst_id;
SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id',0));

-- sid and seria#
select S.USERNAME, s.sid, s.SERIAL#, t.sql_id, sql_text from v$sqltext_with_newlines t,V$SESSION s where t.address =s.sql_address and s.sid=&sid and s.SERIAL#=&serial;

-- kill
alter system kill session '&sid,&serial,@&inst_id' immediate;


-- kill CKS 的例子
select s.inst_id, s.sql_id, s.sid, s.serial#, p.spid, s.machine, s.username, to_char(  s.logon_time, 'yyyy-mm-dd_hh24:mi:ss' ) logon_time, s.program, round(PGA_USED_MEM/1024/1024,0) PGA_USED_MEM, round(PGA_ALLOC_MEM/1024/1024,0) PGA_ALLOC_MEM from gv$session s , gv$process p Where s.paddr = p.addr and s.inst_id = p.inst_id and PGA_USED_MEM/1024/1024 > 10 and s.username = 'CKS' and s.logon_time < sysdate-(1/24)  order by logon_time;
-- kill CKS 的例子
select 'ALTER SYSTEM KILL SESSION '''||s.sid||','||s.serial#||''' IMMEDIATE;'from gv$session s , gv$process p Where s.paddr = p.addr and s.inst_id = p.inst_id and PGA_USED_MEM/1024/1024 > 10 and s.username = 'CKS' and s.logon_time < sysdate-(1/24)  order by logon_time;




-- 群里大神的推荐查询 event
set lines 150
col event for a50
set pages 1000
col username for a30
select inst_id,username,event,count(*) from gv$session where wait_class#<>6 group by inst_id,username,event order by 1,3 desc;
select inst_id,username,event,sql_id,count(*) from gv$session where wait_class#<>6 group by inst_id,username,event,sql_id order by 1,5;


--
-- sid & sql_id
column USERNAME format a10;
column 2 format a10;
column OSUSER format a10;
column SQL_ID format a15;
select S.USERNAME, s.sid, s.osuser, t.sql_id, sql_text from v$sqltext_with_newlines t,V$SESSION s
where t.address =s.sql_address and t.hash_value = s.sql_hash_value and s.status = 'ACTIVE' and s.sid='&sid'
and s.username <> 'SYSTEM' order by s.sid,t.piece ;
--
USERNAME          SID OSUSER     SQL_ID          SQL_TEXT
---------- ---------- ---------- --------------- ----------------------------------------------------------------
SYS                 1 oracle     1h50ks4ncswfn   ALTER DATABASE OPEN
SYS                33 oracle     5tc4frsnvrv64   select S.USERNAME, s.sid, s.osuser, t.sql_id, sql_text from v$sq
SYS                33 oracle     5tc4frsnvrv64   ltext_with_newlines t,V$SESSION s
                                                 where t.address =s.sql_address


-- check sql
alter session set nls_date_format='yyyy-mm-dd_hh24:mi:ss';     
select * from v$sqlarea a where A.Sql_fullText like '%TICKETRECORD_HIST%';
select sql_text, module, to_char( last_active_time, 'yyyy-mm-dd_hh24:mi:ss' )  from v$sqlarea a where A.Sql_fullText like '%TICKETRECORD_HIST%';
select sql_id, sql_text, module, to_char( last_active_time, 'yyyy-mm-dd_hh24:mi:ss' )  from v$sqlarea a where A.Sql_fullText like '%TICKETRECORD_HIST%';



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
select TABLE_NAME, TABLESPACE_NAME, LAST_ANALYZED, NUM_ROWS from user_tables where TABLESPACE_NAME not in ('SYSTEM','SYSAUX') order by NUM_ROWS;
--
--
TABLE_NAME		       TABLESPACE_NAME		      LAST_ANALYZED	    NUM_ROWS
------------------------------ ------------------------------ ------------------- ----------
TICKETRECORD_ARCH	       TICKET_TABLESPACES	      2018-01-17 03:25:41  103176198
TICKETRECORD		       TICKET_TABLESPACES	      2018-01-24 06:21:31  115035999
TICKETRECORD_HIST	       USERS			      2017-11-18 02:46:58  142669418
SEATUPDATELOG		       USERS			      2017-11-18 00:32:06  174053525
VOYAGEMAPDETAIL 	       USERS			      2018-01-18 03:10:56  354257297
-- oltp PE 299个非空表 42个空表, POE 59个非空表
-- zjzz PE 335个非空表, 88 个空表


-- table size
SELECT
   owner, 
   table_name, 
   TRUNC(sum(bytes)/1024/1024) Meg,
   ROUND( ratio_to_report( sum(bytes) ) over () * 100) Percent
FROM
(SELECT segment_name table_name, owner, bytes
     FROM dba_segments
     WHERE segment_type IN ('TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION')
     UNION ALL
     SELECT i.table_name, i.owner, s.bytes
     FROM dba_indexes i, dba_segments s
     WHERE s.segment_name = i.index_name
     AND   s.owner = i.owner
     AND   s.segment_type IN ('INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION')
     UNION ALL
     SELECT l.table_name, l.owner, s.bytes
     FROM dba_lobs l, dba_segments s
     WHERE s.segment_name = l.segment_name
     AND   s.owner = l.owner
     AND   s.segment_type IN ('LOBSEGMENT', 'LOB PARTITION')
     UNION ALL
     SELECT l.table_name, l.owner, s.bytes
     FROM dba_lobs l, dba_segments s
     WHERE s.segment_name = l.index_name
     AND   s.owner = l.owner
     AND   s.segment_type = 'LOBINDEX')
WHERE owner in UPPER('&owner')
GROUP BY table_name, owner
HAVING SUM(bytes)/1024/1024 > 10  /* Ignore really small tables */
ORDER BY SUM(bytes) desc;   zjzzdg  1578646298524   SQL 1   2.761



-- DDL
TRUNCATE TABLE employees_demo; 


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
select s.sid, s.serial#, s.username, s.machine, s.osuser, cpu_time, (elapsed_time/1000000)/60 as minutes, sql_text from gv$sqlarea a, gv$session s where s.sql_id = a.sql_id and s.sid = '&sid' ;

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



-- ------------------------------
-- DBLINK
-- ------------------------------

-- create dblink
-- https://dba.stackexchange.com/questions/54185/create-database-link-on-oracle-database-with-2-databases-on-different-machines
--list dblik
SELECT * FROM ALL_DB_LINKS;
SELECT DB_LINK FROM all_db_links;
-- drop
DROP DATABASE LINK remote_dblink;
DROP PUBLIC DATABASE LINK remote_dblink;
-- create
CREATE DATABASE LINK remote_dblink CONNECT TO SYSTEM IDENTIFIED BY oracle USING 'remotedb';
CREATE PUBLIC DATABASE LINK remote_dblink CONNECT TO SYSTEM IDENTIFIED BY oracle USING 'remotedb';
-- check it
select count(1) from schema.testtable@remote_dblink ; 


-- 查看是否有权限进程dblink操作
select * from user_sys_privs where privilege like upper('&db_link');  





-- Rman备份再恢复
-- 1 copy backupset and autobackup to /home/oracle
-- 2 create pfile, db_name需一致
cat > ~/initorsid1.ora << EOF
*.db_recovery_file_dest_size=10g
*.db_recovery_file_dest='+DATA'
*.compatible='11.2.0.4.0'
*.db_name=oradb
EOF
-- 3 startup nomount
SQL> startup nomount pfile='/home/oracle/initorsid1.ora';
-- 4 restore controlfile from backup piece
rman target / 
RMAN> set dbid 2748650428
RMAN> restore controlfile from '/home/oracle/backup/ORADB/AUTOBACKUP/s_1012151711.288.1012151711';
-- 5 startup mount
SQL> alter system set control_files='+DATA/xxxx';
SQL> alter database mount;
-- 6 restore recover database
RMAN> restore database; 
RMAN> recover database [ until SCN xxx ];
RMAN> alter database open resetlogs

-- 注：AIX系统oracle数据库自动启动：
-- 1、vi /etc/oratab  并添加：
ORACLE_SID:ORACLE_HOME:Y
-- 2、vi $ORACLE_HOME/bin/dbstart
-- 对ORACLE_HOME_LISTENER一行进行修改，使其等于$ORACLE_HOME
-- 3、编写数据库启动脚本  vi /etc/rc.startdb
-- 添加：
su - oracle "-c /u01/app/oracle/product/11.2.0/db_1/bin/dbstart"
-- 4、为此文件授予可执行的权限：chmod +x /etc/rc.startdb
-- 5、vi /etc/inittab
-- 添加：
startdb:2:once:/etc/rc.startdb
-- 或者使用mkitab命令将启动条目添加到/etc/initab文件中
#mkitab "startdb:2:once:/etc/rc.startdb > /dev/null 2>&1"


-- crs 命令

-- 启动 crs
[root@rac1 ~]# /oracle/11.2.0/grid/gridhome/bin/crsctl start crs
-- 停止
[root@rac1 ~]# /u01/app/11.2.0/grid/bin/crsctl stop crs
[root@rac1 ~]# /u01/app/11.2.0/grid/bin/crsctl stop crs -f
-- 查看当前的服务器启动情况，
$ crs_stat -t
-- 删除旧服务
$ srvctl remove database -d orcl
-- 添加服务 用oracle用户
oracle@host ~ $ srvctl add database -d ee -o /u01/app/oracle/product/11.2.0/dbhome_1 
srvctl add database -d $ORACLE_SID -o $ORACLE_HOME

-- standalone db
sudo $GRID_HOME/bin/crsctl delete resource  ora.oradb.db
-- rac
srvctl add database -d db_unique_name -r PRIMARY -n db_name -o $ORACLE_HOME 
srvctl add instance -d db_unique_name -i $ORACLE_SID -n $HOSTNAME
srvctl add instance -d db_unique_name -i $ORACLE_SID -n $HOSTNAME


srvctl add database -d db_unique_name -o ORACLE_HOME [-x node_name] [-m domain_name] [-p spfile] [-r {PRIMARY|PHYSICAL_STANDBY|LOGICAL_STANDBY|SNAPSHOT_STANDBY}] [-s start_options] [-t stop_options] [-n db_name] [-y {AUTOMATIC|MANUAL}] [-g server_pool_list] [-a "diskgroup_list"]

srvctl modify database -d db_unique_name [-n db_name] [-o ORACLE_HOME] [-u oracle_user] [-m domain] [-p spfile] [-r {PRIMARY|PHYSICAL_STANDBY|LOGICAL_STANDBY|SNAPSHOT_STANDBY}] [-s start_options] [-t stop_options] [-y {AUTOMATIC|MANUAL}] [-g "server_pool_list"] [-a "diskgroup_list"|-z]

srvctl add service -d db_unique_name -s service_name -r preferred_list [-a available_list] [-P {BASIC|NONE|PRECONNECT}]
[-l [PRIMARY|PHYSICAL_STANDBY|LOGICAL_STANDBY|SNAPSHOT_STANDBY]
[-y {AUTOMATIC|MANUAL}] [-q {TRUE|FALSE}] [-j {SHORT|LONG}]
[-B {NONE|SERVICE_TIME|THROUGHPUT}] [-e {NONE|SESSION|SELECT}]
[-m {NONE|BASIC}] [-x {TRUE|FALSE}] [-z failover_retries] [-w failover_delay]



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

-- 启动
$ crs_start ora.ee.db
Attempting to start `ora.ee.db` on member `orcl`
Start of `ora.ee.db` on member `orcl` succeeded.

-- 关闭所有服务
$ crs_stop -all



-- ------------------------------
-- ASM
-- ------------------------------

-- 查看存储裸设备
fdisk -l 和 powermt display dev=all 确认存储盘信息


-- 
alter diskgroup data mount;
alter diskgroup ocr mount;
alter diskgroup ocr dismount;


-- asm creating DATA disk group
CREATE DISKGROUP DATA NORMAL REDUNDANCY DISK '/dev/raw/raw1';
CREATE DISKGROUP FRA EXTERNAL REDUNDANCY DISK 'dev/raw/raw2';

-- diskgroup add disk
ALTER DISKGROUP DATA ADD DISK '/dev/raw/raw4';

-- diskgroup 
DROP DISKGROUP dgroup_01 INCLUDING CONTENTS;

-- asm drop
ASMCMD> rm -rf DATA
ASMCMD> dropdg -r data
ASMCMD> lsdg

-- asm create disgroup
sudo /etc/init.d/oracleasm createdisk ASMDISK /dev/sdf1
select path,header_status from v$asm_disk;
CREATE DISKGROUP DATA EXTERNAL REDUNDANCY DISK 'ORCL:ASMDISK' ;

CREATE DISKGROUP data NORMAL REDUNDANCY
  FAILGROUP controller1 DISK '/dev/raw/raw4' NAME data_a1, '/dev/raw/raw5' NAME data_a2
  FAILGROUP controller2 DISK '/dev/raw/raw6' NAME data_b1, '/dev/raw/raw7' NAME data_b2
/

CREATE DISKGROUP data NORMAL REDUNDANCY FAILGROUP controller1 DISK 
'/dev/raw/raw4' NAME data1,
'/dev/raw/raw5' NAME data2
/


-- asm replace disk
-- http://blog.itpub.net/30126024/viewspace-2155829/
select path,failgroup,mount_status,mode_status,header_status,state from v$asm_disk order by failgroup, path;

PATH                                     FAILGROUP                      MOUNT_S MODE_ST HEADER_STATU STATE
---------------------------------------- ------------------------------ ------- ------- ------------ --------
ORCL:DATA                                DATA                           CACHED  ONLINE  MEMBER       NORMAL
ORCL:FRA                                 FRA                            CACHED  ONLINE  MEMBER       NORMAL
ORCL:ORC1                                ORC1                           CACHED  ONLINE  MEMBER       NORMAL
ORCL:ORC2                                ORC2                           CACHED  ONLINE  MEMBER       NORMAL
ORCL:ORC3                                ORC3                           CACHED  ONLINE  MEMBER       NORMAL
ORCL:NEWDATA                                                            CLOSED  ONLINE  PROVISIONED  NORMAL
ORCL:NEWFRA                                                             CLOSED  ONLINE  PROVISIONED  NORMAL
ORCL:NEWOCR1                                                            CLOSED  ONLINE  PROVISIONED  NORMAL
ORCL:NEWOCR2                                                            CLOSED  ONLINE  PROVISIONED  NORMAL
ORCL:NEWOCR3                                                            CLOSED  ONLINE  PROVISIONED  NORMAL

-- add disk
alter diskgroup FRA add disk 'ORCL:NEWFRA'  rebalance power 10;
-- check operation
select * from v$asm_operation;
-- check disk
select a.path,a.name,a.mode_status,b.name diskgroupname,b.type from v$asm_disk a,v$asm_diskgroup b where a.group_number=b.group_number and b.name='FRA';
-- drop disk
alter diskgroup FRA drop disk 'FRAFAILGROUP' rebalance power 10;
-- check operation
select * from v$asm_operation;

-- 无法删除INIT ,

SQL> SELECT name, header_status, path FROM V$ASM_DISK; 

NAME			       HEADER_STATUS	    PATH
------------------------------ -------------------- -------------------------
			       FORMER		    ORCL:ASMDISK2
			       FORMER		    ORCL:ASMDISK3
			       FORMER		    ORCL:ASMDISK4
ASMDISK1		       MEMBER		    ORCL:ASMDISK1


SQL> SELECT name, header_status, path FROM V$ASM_DISK; 

NAME			       HEADER_STATUS	    PATH
------------------------------ -------------------- -------------------------
			       MEMBER		    ORCL:ASMDISK1
			       FORMER		    ORCL:ASMDISK4
			       FORMER		    ORCL:ASMDISK3
			       FORMER		    ORCL:ASMDISK2

SQL> DROP DISKGROUP INIT FORCE INCLUDING CONTENTS;

Diskgroup dropped.


select group_number, operation, state, est_minutes from v$asm_operation ;
--
GROUP_NUMBER OPERA STAT EST_MINUTES
------------ ----- ---- -----------
 1            REBAL RUN  2
 1            REBAL WAIT 0


-- create asm diskgroup
-- https://www.hhutzler.de/blog/using-asm-spfile/


-- create
CREATE DISKGROUP FRA  EXTERNAL REDUNDANCY DISK 'ORCL:ASMDISK1' ; 
CREATE DISKGROUP OCR  EXTERNAL REDUNDANCY DISK 'ORCL:ASMDISK2' ; 
CREATE DISKGROUP DATA EXTERNAL REDUNDANCY DISK 'ORCL:ASMDISK3', 'ORCL:ASMDISK4' ; 


-- check
column path format a20
select path, group_number group_#, disk_number disk_#, mount_status, header_status, state, total_mb, free_mb from v$asm_disk order by group_number;
--
PATH            GROUP_#     DISK_# MOUNT_S HEADER_STATU STATE      TOTAL_MB    FREE_MB
-------------------- ---------- ---------- ------- ------------ -------- ---------- ----------
/dev/raw/raw1             1      0 CACHED  MEMBER   NORMAL         1019    710
/dev/raw/raw2             1      1 CACHED  MEMBER   NORMAL         1019    712
/dev/raw/raw3             1      2 CACHED  MEMBER   NORMAL         1019    709
/dev/raw/raw4             2      0 CACHED  MEMBER   NORMAL        20473  20380
/dev/raw/raw5             3      0 CACHED  MEMBER   NORMAL        20473  20380

-- check
select state,redundancy,total_mb,free_mb,name,failgroup from v$asm_disk;


-- asmcmd copy
ASMCMD> cp /u01/oracle/oradata/test1.dbf +DATA/LONDON/DATAFILE/test.dbf
copying /u01/oracle/oradata/test1.dbf -> +DATA/LONDON/DATAFILE/test.dbf

-- asmcmd copy multiple
for i in $(asmcmd ls +DG_AL/EMREP/ARCHIVELOG/2012_12_04); do
  asmcmd cp +DG_AL/EMREP/ARCHIVELOG/2012_12_04/$i /u01
done

-- 更换数据文件到asm
-- https://www.thegeekdiary.com/how-to-move-a-datafile-from-filesystem-to-asm-using-asmcmd-cp-command/
alter database datafile 5 offline;
! asmcmd cp /u01/app/oracle/oradata/EE/test_tablespace01.dbf +DATA/EE/DATAFILE/test_tablespace01.dbf
alter database rename file '/u01/app/oracle/oradata/EE/test_tablespace01.dbf' to '+DATA/EE/DATAFILE/test_tablespace01.dbf';
alter database recover datafile 5; 
alter database datafile 5 online ; 




-- 1. 原因是OCR 区挂载失败，导致CRS daemon异常
[grid]$crs_stat -t
CRS-0184: Cannot communicate with the CRS daemon.

[oragrid]$which crs_stat
/oracle/11.2.0/grid/gridhome/bin/crs_stat
[oragrid]$/oracle/11.2.0/grid/gridhome/bin/crs_stat -t
CRS-0184: Cannot communicate with the CRS daemon.


-- 2. log 查异常原因
ls -lh $CRS_HOME/log/`hostname`/crsd/crsd.log
ls -lh $GRID_HOME/log/`hostname`/crsd/crsd.log


-- 3.  ocr是oracle集群的注册文件，位于asm
[oragrid ~]$ocrcheck 
PROT-602: Failed to retrieve data from the cluster registry
PROC-26: Error while accessing the physical storage


-- 4.  查看diskgroup并尝试挂载OCR分区
select name,state from v$asm_diskgroup;
--
NAME                           STATE     
------------------------------ -----------
OCR                            MOUNTED    
ARCDG1                         CONNECTED  
DATADG1                        DISMOUNTED


alter diskgroup ocr mount;
--
Diskgroup altered.


--check
[oragrid]$asmcmd
ASMCMD> lsdg
State    Type    Rebal  Sector  Block       AU  Total_MB  Free_MB  Req_mir_free_MB  Usable_file_MB  Offline_disks  Voting_files  Name
MOUNTED  EXTERN  N         512   4096  1048576   1023986   601547                0          601547              0             N  ARCDG1/
MOUNTED  EXTERN  N         512   4096  1048576   2559965  1850805                0         1850805              0             N  DATADG1/
MOUNTED  NORMAL  N         512   4096  1048576      3069     2143             1023             560              0             Y  OCR/



-- 按上面挂载后root运行启动服务
[root ~]# /oracle/11.2.0/grid/gridhome/bin/ocrcheck


-- 这个会失败， 尝试启动crs，但失败。只能启动cluster
[root ~]# /oracle/11.2.0/grid/gridhome/bin/crsctl start crs
CRS-4640: Oracle High Availability Services is already active
CRS-4000: Command Start failed, or completed with errors.
[root ~]# /oracle/11.2.0/grid/gridhome/bin/crsctl start cluster
CRS-2672: Attempting to start 'ora.crsd' on 'db2'
CRS-2676: Start of 'ora.crsd' on 'db2' succeeded


-- 处理最终结果，target和state一致，并且有rac1和rac2的信息
[oragrid]$crs_stat -t


-- 勒索病毒
select 'DROP TRIGGER '||owner||'."'||TRIGGER_NAME||'";' from dba_triggers where
TRIGGER_NAME like  'DBMS_%_INTERNAL%'
union all
select 'DROP PROCEDURE '||owner||'."'||a.object_name||'";' from DBA_PROCEDURES a
where a.object_name like 'DBMS_%_INTERNAL% '
/


-- size of all objects in your schema
select sum(bytes)/1024/1024 MB from dba_segments where owner = 'CKSP'; 

MB
----------
187854.063





-- ------------------------------
-- Large table
-- ------------------------------



-- 查询是否启用自动SQL调优作业
col CLIENT_NAME format a35
col CLIENT_NAME format a35
select client_name,status,consumer_group,window_group from dba_autotask_client order by client_name;

CLIENT_NAME			    STATUS   CONSUMER_GROUP		    WINDOW_GROUP
----------------------------------- -------- ------------------------------ ------------------------------
auto optimizer stats collection     ENABLED  ORA$AUTOTASK_STATS_GROUP	    ORA$AT_WGRP_OS
auto space advisor		    ENABLED  ORA$AUTOTASK_SPACE_GROUP	    ORA$AT_WGRP_SA
sql tuning advisor		    ENABLED  ORA$AUTOTASK_SQL_GROUP	    ORA$AT_WGRP_SQ



--  查看SQL调优顾问最近几次的运行情况
select task_name,status,to_char(execution_end,'DD-MON-YY HH24:MI') from
dba_advisor_executions where task_name='SYS_AUTO_SQL_TUNING_TASK' order by
execution_end
/

TASK_NAME		       STATUS	   TO_CHAR(EXECUTION_END
------------------------------ ----------- ------------------------
SYS_AUTO_SQL_TUNING_TASK       COMPLETED   09-NOV-18 22:53
SYS_AUTO_SQL_TUNING_TASK       COMPLETED   10-NOV-18 06:00



-- SQL建议
set  linesize 3000 PAGESIZE 0 LONG 100000
select DBMS_SQLTUNE.SCRIPT_TUNING_TASK('SYS_AUTO_SQL_TUNING_TASK') from dual;


-----------------------------------------------------------------
-- Script generated by DBMS_SQLTUNE package, advisor framework -
-
-- Use this script to implement some of the recommendations    --
-- made by the SQL tuning advisor.
 --
--							       --
-- NOTE: this script may need to be edited for your system
   --
--	 (index names, privileges, etc) before it is executed. --
----------------------------------------------------------
-------
execute dbms_stats.gather_table_stats(ownname => 'SYSMAN', tabname => 'MGMT_METRICS_RAW', estimate_percent => DBMS_STATS.A
UTO_SAMPLE_SIZE, method_opt => 'FOR ALL COLUMNS SIZE AUTO');



-- 查看执行计划
SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id',0));

-- change db_namem, db_unique_name, instance_name
-- https://docs.oracle.com/database/121/SUTIL/GUID-6CC9CA73-8C0C-4750-8D0E-ADFDB047E4AE.htm#SUTIL1546
STARTUP MOUNT
oracle $> nid TARGET=SYS DBNAME=test_db SETNAME=YES
-- change ORACLE_SID and pfile
startup 

-- change service_name (https://dba.stackexchange.com/questions/49245/cannot-change-service-name-for-oracle)
alter system set db_domain='' scope=spfile; 
alter system set service_names = 'mydb' scope = both;




-- 无法添加tempfile
-- 由于生产库启用了GGS_DDL_TRIGGER_BEFORE触发器导致，此触发器为OGG的触发器，官方解决方案为：
-- 1.在生产库禁用GGS_DDL_TRIGGER_BEFORE触发器，
-- 2.ADG同步禁用触发器  
-- 3.再次尝试手动添加tempfile
select owner,trigger_name,status from dba_triggers where trigger_name like '%GGS%';
alter trigger sys.GGS_DDL_TRIGGER_BEFORE disable;

DBA_TEMP_FILES
DBA_DATA_FILES
DBA_TABLESPACES
DBA_TEMP_FREE_SPACE
V$TEMPFILE
V$TEMP_SPACE_HEADER
V$TEMPORARY_LOBS
V$TEMPSTAT
V$TEMPSEG_USAGE


-- ------------------------------
-- Large table
-- ------------------------------

-- duplicate large table
1. Get DDL + partitions + indexes of The original table.
2. create new table using DDL
create table SMALL_TABLE as select * from TABLE where CHECKINTIME > sysdate - 3*365;
create table SMALL_TABLE as select * from ( select * from TABLE order by id ) where rownum < 20000000; 
3. drop old table and rename small_table to old.
4. Created the new table using the ddl script collected in point 1 + all indexes and partitions. 
a. constraint
ALTER TABLE TABLE_NAME ADD CONSTRAINT "CONSTRAINT_NAME" FOREIGN KEY (FK_ID) REFERENCES OTHER_TABLE(FK_ID);
ALTER TABLE TABLE_NAME ADD CONSTRAINT "CONSTRAINT_NAME" PRIMARY KEY ("ID");
b. index
c. default value
alter table TABLE modify( "INSERTTIME" DATE DEFAULT SYSDATE );
5. Collected fresh statistics.

-- What is the purpose of logging/nologging option in Oracle
-- https://stackoverflow.com/questions/34073532/what-is-the-purpose-of-logging-nologging-option-in-oracle
SQL> alter table user1.LDM_table1 nologging; 
1. nologging option is set redo logs will NOT be generated while inserting data
2. never to use nologging option under Data guard setup


-- copy with where
create table TESTTICKETTRANSACTION as select * from TICKETTRANSACTION where SOLDDATE > sysdate - 3*365  ; 


-- startup upgrade ORA-39700: database must be opened with UPGRADE option
-- https://dba.stackexchange.com/questions/169403/how-to-solve-ora-39710-problem
startup upgrade
@$ORACLE_HOME/rdbms/admin/catupgrd.sql
@$ORACLE_HOME/rdbms/admin/utlrp.sql
-- https://dba010.com/2017/05/20/upgrading-timezone-manually-in-12c/
select * from sys.registry$database;
create table registry$database_b as select * from registry$database;
INSERT into registry$database
  (platform_id, platform_name, edition, tz_version)
 VALUES ((select platform_id from v$database),
     (select platform_name from v$database),
      NULL,
      (select version from v$timezone_file));
select * from sys.registry$database;
commit;
 delete from sys.registry$database where TZ_VERSION is NULL;
commit;

-- ORA-02264: name already used by an existing constraint
--drop constraint
alter table xxx drop constraint owner_tp_car_vin_nn; 
--create constraint while creating table
CREATE TABLE Orders (
    OrderID int NOT NULL PRIMARY KEY,
    OrderNumber int NOT NULL,
    PersonID int FOREIGN KEY REFERENCES Persons(PersonID)
);
-- add constraint
ALTER TABLE Orders ADD CONSTRAINT "KEY_NAME" FOREIGN KEY (PersonID) REFERENCES Persons(PersonID);
ALTER TABLE Orders ADD CONSTRAINT "KEY_NAME" PRIMARY KEY ("ID");


alter table VOYAGEMAPDETAIL add CONSTRAINT "VOYAGEMAPDETAIL_PK" PRIMARY KEY ("ID")
EXEC sp_rename N'schema.MyIOldConstraint', N'MyNewConstraint', N'OBJECT'
sp_rename 'HumanResources.PK_Employee_BusinessEntityID', 'PK_EmployeeID';


-- ORA-00245
-- ORA-00245: control file backup failed; target is likely on a local file system
-- 需要讲控制文件snapshot放置在共享存储中
RMAN> CONFIGURE SNAPSHOT CONTROLFILE NAME TO '+<DiskGroup>/snapcf_<DBNAME>.f';

-- 需要 dbms_crypto 加密
-- 检查
select DBMS_CRYPTO.RandomInteger from dual;
-- install
@?/rdbms/admin/dbmsobtk.sql
@?/rdbms/admin/prvtobtk.plb
-- grant to user
Grant execute on dbms_crypto to USER;
Grant execute on dbms_sqlhash to USER;
Grant execute on dbms_obfuscation_toolkit to USER;
Grant execute on dbms_obfuscation_toolkit_ffi to USER;
Grant execute on dbms_crypto_ffi to USER;

-- disalbe Cluster Health Monitory process CHM (ORA.CRF)
-- boot status
crsctl stat res -t -init
-- 


-- disable tfa
-- status
/u01/app/11.2.0/grid/tfa/bin/tfactl print status
-- stop
/etc/init.d/init.tfa stop


-- 从backupset中恢复指定的archivelog file
declare
devtype varchar2(256);
done boolean;
begin
    devtype:=sys.dbms_backup_restore.deviceAllocate(type=>'',ident=>'t2');
    sys.dbms_backup_restore.restoreSetArchivedLog(destination=>'/archivelog02');
    sys.dbms_backup_restore.restoreArchivedLog(thread=>2,sequence=>51500);
    sys.dbms_backup_restore.restoreBackupPiece(done=>done,handle=>'/backup/zlhis/rman/AL_ZLHIS_20141030_862336902_23768_1',params=>null);
    sys.dbms_backup_restore.deviceDeallocate;
end;
--
--destination=>'/archivelog02指定恢复出来归档日志的存放系统目录位置，thread表示rac的thread号，sequence为需要恢复的那个归档日志序列号，handle表示备份集的绝对路径。

-- 抢救
bbed, resetlogs scn, fuzzy 


-- high water mark HWM

ANALYZE TABLE VOYAGEMAPDETAIL_BAK ESTIMATE/COMPUTE STATISTICS;
SELECT blocks, empty_blocks, num_rows FROM user_tables WHERE table_name = VOYAGEMAPDETAIL_BAK;

-- kill oracle with ORACLE_SID=EE

-bash-4.2$ pgrep -f ora_.*EE | xargs kill -9
sql> startup 
-- 启动的时候报错ORA-01081, 数据库已经启动

-- 使用ipcs查看进程
-bash-4.2$ ipcs -pmb

------ Shared Memory Creator/Last-op PIDs --------
shmid      owner      cpid       lpid      
163840     oracle     2290       17273     

-- 杀掉该进程
-bash-4.2$ ipcrm -m 163840


-- drop and create create sequence
-- drop sequence 
select 'drop sequence ' || sequence_name || ';' from user_sequences;
-- create sequence
set pagesize 200
set linesize 600
select to_char (dbms_metadata.get_ddl ('SEQUENCE', user_objects.object_name)) as ddl from user_objects where object_type = 'SEQUENCE';
-- $ perl -pe 's/\s+$/;\n/' /tmp/test.sql 



-- ------------------------------
-- OMF
-- ------------------------------
-- http://www.dba-oracle.com/real_application_clusters_rac_grid/omf.html


-- 新增加文件将从 $ORACLE_HOME/dbs调整为 ${DB_CREATE_FILE_DEST}/${uniq_db_name}/datafile/

alter system set DB_CREATE_FILE_DEST='/u01/app/oracle/oradata' scope=both;
CREATE TABLESPACE tbs_1;
select * from dba_data_files;




-- ------------------------------
-- Automatic Maintenance and Optimizer Statistic Collection
-- ------------------------------
-- https://www.carajandb.com/en/blog/2014/automatic-maintenance-and-optimizer-statistic-collection-managing-with-12c-and-11g/
-- status
-- 1 auto optimizer stats collection
-- 2 auto space advisor
-- 3 sql tuning advisor
select client_name, status, attributes from dba_autotask_client;

-- DBA_AUTOTASK_SCHEDULE supplies the configured time windows for the next 32 days:
col format START_TIME format a40
col DURATION  format a30
select window_name, autotask_status, optimizer_stats from dba_autotask_window_clients;

-- By default seven time windows are configured
col DURATION format a20
col COMMENTS format a50
col NEXT_START_DATE format a40
select WINDOW_NAME,NEXT_START_DATE,DURATION,ENABLED,ACTIVE,COMMENTS from DBA_SCHEDULER_WINDOWS;

-- check done jobs
select * from DBA_AUTOTASK_JOB_HISTORY;

-- Activation / Deactivation
-- disable
exec dbms_auto_task_admin.disable;

-- Following command deactivates only Optimizer Stats Collection:
begin  
dbms_auto_task_admin.disable(
    client_name => 'auto optimizer stats collection',
    operation => NULL,
    window_name => NULL);
end;
/ 

-- Changing START time
begin  
dbms_scheduler.set_attribute(
    name      => 'MONDAY_WINDOW',
    attribute => 'repeat_interval',
    value     => 'freq=daily;byday=MON;byhour=5;byminute=0; bysecond=0');
end;
/ 

--  Changing DURATION
begin
  dbms_scheduler.set_attribute(
    name      => 'MONDAY_WINDOW',
    attribute => 'duration',
    value     => numtodsinterval(5, 'hour'));
end;
/ 

-- CREATE NEW WINDOW
begin
  dbms_scheduler.create_window(
    window_name     => 'SPECIAL_WINDOW',
    duration        =>  numtodsinterval(3, 'hour'),
    resource_plan   => 'DEFAULT_MAINTENANCE_PLAN',
    repeat_interval => 'FREQ=DAILY;BYHOUR=10;BYMINUTE=0;BYSECOND=0');
  dbms_scheduler.add_group_member(
    group_name  => 'MAINTENANCE_WINDOW_GROUP',
    member      => 'SPECIAL_WINDOW');
end;
/


--- 

-- Run SQL Tuning Advisor For A Sql_id

-- Create Tuning Task
DECLARE
  l_sql_tune_task_id  VARCHAR2(100);
BEGIN
  l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
                          sql_id      => '5fmyz01ptmc7f',
                          scope       => DBMS_SQLTUNE.scope_comprehensive,
                          time_limit  => 500,
                          task_name   => '5fmyz01ptmc7f_tuning_task',
                          description => 'Tuning task1 for statement 5fmyz01ptmc7f');
  DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/
 

-- Execute Tuning task: 
EXEC DBMS_SQLTUNE.execute_tuning_task(task_name => '5fmyz01ptmc7f_tuning_task'); 


-- read tuning task
set long 65536
set longchunksize 65536
set linesize 100
select dbms_sqltune.report_tuning_task('5fmyz01ptmc7f_tuning_task') from dual;
 



-- explain plan
-- display running explain plan
select * from table(dbms_xplan.display);
-- display specified sql_id plan
SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id'));
SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR('&sql_id',&plan_hash_value));
-- from baseline
SELECT * FROM TABLE(DBMS_XPLAN.display_sql_plan_baseline(plan_name=>'SQL_PLAN_agz791au8s6jg30a4b3a6'));
-- Display all the explain plans of a sql_id from a sql set DBACLASS_SET, sql_id-dwdx28sdfsdf5
SELECT * FROM TABLE(dbms_xplan.display_sqlset('DBACLASS_SET', 'dwdx28sdfsdf5'));
-- Display explain plan for particular plan_hash_value - 983987987
SELECT * FROM TABLE(dbms_xplan.display_sqlset('DBACLASS_SET','dwdx28sdfsdf5', 983987987));
 

--  

-- DBA_HIST_SQL_PLAN get plan_hash_value from sqlid
select s.begin_interval_time , s.end_interval_time , q.snap_id , q.dbid , q.sql_id , q.plan_hash_value , q.optimizer_cost , q.optimizer_mode from
         dba_hist_sqlstat  q , dba_hist_snapshot s where q.dbid=&dbid and q.sql_id  = '&sql_id' and q.snap_id = s.snap_id
         and s.begin_interval_time between sysdate-7 and sysdate order by s.snap_id desc ;


BEGIN_INTERVAL_TIME END_INTERVAL_TIME      SNAP_ID       DBID SQL_ID                                PLAN_HASH_VALUE                          OPTIMIZER_COST OPTIMIZER_
------------------- ------------------- ---------- ---------- ------------- --------------------------------------- --------------------------------------- ----------
2020-04-10 20:00:38 2020-04-10 21:00:43     106105 1227174256 6gvch1xu9ca3g                                       0                                       0 ALL_ROWS  
2020-04-10 19:00:34 2020-04-10 20:00:38     106104 1227174256 6gvch1xu9ca3g                                       0                                       0 ALL_ROWS  

-- get explain plan from sql_id and plan_hash_value
SELECT * FROM table(DBMS_XPLAN.DISPLAY_AWR('&sql_id', &plan_hash_value ));


-- ------------------------------
-- cache 
-- ------------------------------
--查看放入Keep的对象
select segment_name, bytes/1024/1024 MB  from dba_segments where BUFFER_POOL = 'KEEP';


SET MARKUP HTML ON SPOOL ON PREFORMAT off ENTMAP off 
set verify off
set timing off
SET ECHO OFF
SET TERMOUT OFF
SET TRIMOUT OFF
set feedback off
set pagesize 50000
set date=select to_char(sysdate,'yyyy-mm-dd') from dual;

column filename new_val filename
select '/tmp/dbcheck_' || to_char(sysdate, 'yyyymmdd' )||'.html' filename from dual;
spool  &&filename


prompt <h1>1. db instance information</h1>
select INSTANCE_NUMBER,INSTANCE_NAME,HOST_NAME,VERSION from V$INSTANCE;

prompt <h1>2. database auto job information</h1>
prompt <h2>2.1. database statistical job information</h2>
prompt <h3>2.1.1. database statistical job status</h3>
select /*+rule*/ client_name,status from dba_autotask_client where client_name='auto optimizer stats collection';

prompt <h3>2.1.2. database statistical job exection history</h3>
select /*+rule*/
 t.client_name "job_name",
 to_char(t.job_start_time, 'yyyy-mm-dd hh24:mi:ss') "job_start_time",
 EXTRACT(DAY FROM t.job_duration) * 24 * 60 +
 EXTRACT(HOUR FROM t.job_duration) * 60 +
 EXTRACT(MINUTE FROM t.job_duration) || ' Min' "job_elapsed_time",
 t.job_error
from DBA_AUTOTASK_JOB_HISTORY t
 where t.client_name = 'auto optimizer stats collection'
 and t.job_start_time > sysdate - 20
 order by "job_start_time" desc;

prompt <h2>2.2. database auto space advisor job information</h2>
prompt <h3>2.2.1. database auto space advisor job status</h3>
select /*+rule*/ client_name,status from dba_autotask_client where client_name='auto space advisor';

prompt <h3>2.2.1. database auto space advisor job exection history</h3>
select /*+rule*/
 t.client_name "job_name",
 to_char(t.job_start_time, 'yyyy-mm-dd hh24:mi:ss') "job_start_time",
 EXTRACT(DAY FROM t.job_duration) * 24 * 60 +
 EXTRACT(HOUR FROM t.job_duration) * 60 +
 EXTRACT(MINUTE FROM t.job_duration) || ' Min' "job_elapsed_time",
 t.job_error
from DBA_AUTOTASK_JOB_HISTORY t
 where t.client_name = 'auto space advisor'
 and t.job_start_time >  sysdate - 20
 order by "job_start_time" desc;

prompt <h2>2.3. database sql tuning advisor job information</h2>
prompt <h3>2.3.1. database sql tuning advisor job status</h3>
select /*+rule*/ client_name,status from dba_autotask_client where client_name='sql tuning advisor';

prompt <h3>2.3.2. database sql tuning advisor job exection history</h3>
select /*+rule*/
 t.client_name "job_name",
 to_char(t.job_start_time, 'yyyy-mm-dd hh24:mi:ss') "job_start_time",
 EXTRACT(DAY FROM t.job_duration) * 24 * 60 +
 EXTRACT(HOUR FROM t.job_duration) * 60 +
 EXTRACT(MINUTE FROM t.job_duration) || ' Min' "job_elapsed_time",
 t.job_error
from DBA_AUTOTASK_JOB_HISTORY t
 where t.client_name = 'sql tuning advisor'
 and t.job_start_time >  sysdate - 20
 order by "job_start_time" desc;

prompt <h1>3. datafile attribute information</h1>
 select ddf.tablespace_name,ddf.file_id,ddf.file_name,ddf.status,
       trunc(ddf.bytes / 1024 / 1024, 2) || 'MB' "size",ddf.autoextensible
  from dba_data_files ddf
union all
select dtf.tablespace_name,dtf.file_id,dtf.file_name,dtf.status,
       trunc(dtf.bytes / 1024 / 1024, 2) || 'MB' "size",dtf.autoextensible    
  from dba_temp_files dtf;

prompt <h1>4. tablespace information</h1>
prompt <h2>4.1. tablespace attribute information</h2>
select dt.tablespace_name,
       dt.status,
       dt.logging,
       dt.extent_management,
       dt.segment_space_management,
       dt.bigfile
  from dba_tablespaces dt;

prompt <h2>4.2. tablespace space using rate without autoextend</h2>
select all_tp.TP_NAME as "TABLESPACE_NAME",
       to_char(trunc(all_tp.TP_ALL_SIZE_KB / 1024, 2), 'FM9999990.0099') ||
       ' MB' as "ACTUAL_SIZE",
       to_char(trunc(free_tp.TPF_SIZE_KB / 1024, 2), 'FM9999990.0099') ||
       ' MB' as "ACTUAL_FREE_SIZE",
       to_char(trunc(free_tp.TPF_SIZE_KB * 100 / all_tp.TP_ALL_SIZE_KB, 2),
               'FM9999990.0099') || '%' as "FREE_RATING"
  from (select ddf.tablespace_name as "TP_NAME",
               sum(ddf.bytes) / 1024 as "TP_ALL_SIZE_KB"
          from DBA_DATA_FILES ddf
         group by ddf.tablespace_name
        union all
        select dtf.tablespace_name as "TP_NAME",
               sum(dtf.bytes) / 1024 as "TP_ALL_SIZE_KB"
          from dba_temp_files dtf
         group by dtf.tablespace_name) all_tp,
       (select dfs.tablespace_name as "TP_NAME",
               sum(dfs.bytes) / 1024 as "TPF_SIZE_KB"
          from DBA_FREE_SPACE dfs
         group by dfs.tablespace_name
        union all
        select tsh.tablespace_name as "TP_NAME",
               sum(tsh.bytes_free) / 1024 as "TPF_SIZE_KB"
          from v$temp_space_header tsh
         group by tsh.tablespace_name) free_tp
 where all_tp.TP_NAME = free_tp.TP_NAME(+);

prompt <h2>4.3. tablespace space really using rate with tempspace</h2>
select all_tp.TP_NAME as "TABLESPACE_NAME",
       to_char(trunc(all_tp.TP_ALL_SIZE_KB / 1024 / 1024, 2),
               'FM9999990.0099') || 'GB' as "REAL_SIZE",
       to_char(trunc(free_tp.TP_FREE_SIZE_KB / 1024 / 1024, 2),
               'FM9999990.0099') || 'GB' as "REAL_FREE_SIZE",
       to_char(trunc(free_tp.TP_FREE_SIZE_KB * 100 / all_tp.TP_ALL_SIZE_KB,
                     2),
               'FM9999990.0099') || '%' as "FREE_RATING"
  from (select sum(decode(sign(ddf.maxbytes - ddf.bytes),
                           1,
                           ddf.maxbytes,
                           ddf.bytes)) / 1024 as "TP_ALL_SIZE_KB",
                ddf.tablespace_name as "TP_NAME"
          from DBA_DATA_FILES ddf
         group by ddf.tablespace_name) all_tp,
       (select sum(ifree_tp.TPF_SIZE_KB) as "TP_FREE_SIZE_KB",
                ifree_tp.TP_NAME
          from (select dfs.bytes / 1024 as "TPF_SIZE_KB",
                         dfs.tablespace_name as "TP_NAME"
                   from DBA_FREE_SPACE dfs
                 union all
                select decode(sign(ddf.maxbytes - ddf.bytes),
                               1,
                               ddf.maxbytes - ddf.bytes,
                               0) / 1024 as "TPF_SIZE_KB",
                        ddf.tablespace_name as "TP_NAME"
                   from DBA_DATA_FILES ddf
                  where ddf.autoextensible = 'YES') ifree_tp
         group by ifree_tp.TP_NAME) free_tp
 where all_tp.TP_NAME = free_tp.TP_NAME(+);

prompt <h2>4.4. tablespace growth information</h2>
select TPS.DATETIME,
       TPS.TPS_NAME,
       to_char(trunc(min(TPS1.TPS_MAX_USED_SIZE - TPS.TPS_MIN_USED_SIZE) / 1024 / 1024, 2),
               'FM9999990.0099') ||
       ' MB' "CHANGE_SIZE",
       rank() OVER(PARTITION BY TPS.TPS_NAME ORDER BY TPS.DATETIME) AS "TPS_GROUP_NUMBER"
  from (select TRUNC(TO_DATE(dhtsu.RTIME, 'MM-DD-YYYY hh24:mi:ss')) "DATETIME",
               t.name "TPS_NAME",
               dhtsu.TABLESPACE_USEDSIZE * p.VALUE "TPS_MIN_USED_SIZE"
          from DBA_HIST_TBSPC_SPACE_USAGE dhtsu,
               (select min(idhtsu.SNAP_ID) "MIN_SNAPID"
                  from DBA_HIST_TBSPC_SPACE_USAGE idhtsu
                 group by TRUNC(TO_DATE(idhtsu.RTIME, 'MM-DD-YYYY hh24:mi:ss'))) dhtsu1,
               (select distinct it.TS#, it.NAME from v$tablespace it) t,
               v$parameter p
         where dhtsu.TABLESPACE_ID = t.ts#
           and p.NAME = 'db_block_size'
           and dhtsu1.MIN_SNAPID = dhtsu.SNAP_ID) TPS,
       (select TRUNC(TO_DATE(dhtsu.RTIME, 'MM-DD-YYYY hh24:mi:ss')) "DATETIME",
               t.name "TPS_NAME",
               dhtsu.TABLESPACE_USEDSIZE * p.VALUE "TPS_MAX_USED_SIZE"
          from DBA_HIST_TBSPC_SPACE_USAGE dhtsu,
               (select max(idhtsu.SNAP_ID) "MAX_SNAPID"
                  from DBA_HIST_TBSPC_SPACE_USAGE idhtsu
                 group by TRUNC(TO_DATE(idhtsu.RTIME, 'MM-DD-YYYY hh24:mi:ss'))) dhtsu1,
               (select distinct it.TS#, it.NAME from v$tablespace it) t,
               v$parameter p
         where dhtsu.TABLESPACE_ID = t.ts#
           and p.NAME = 'db_block_size'
           and dhtsu1.MAX_SNAPID = dhtsu.SNAP_ID) TPS1
 where TPS.DATETIME = TPS1.DATETIME
   and TPS.TPS_NAME = TPS1.TPS_NAME
 group by TPS.DATETIME, TPS.TPS_NAME;

prompt <h2>4.5. sysaux tablespace information</h2>
col owner format a20
col segment_name format a40
col segment_type format a20
col size format a10
select owner, segment_name, segment_type, bytes / 1024 / 1024 || ' Mb' "size"
  from (select owner, segment_name, segment_type, bytes
          from dba_segments
         where tablespace_name = 'SYSAUX'
         order by bytes desc)
 where rownum < 10;

prompt <h2>4.6. system tablespace information</h2>
select owner, segment_name, segment_type, bytes / 1024 / 1024 || ' Mb' "size"
  from (select owner, segment_name, segment_type, bytes
          from dba_segments
         where tablespace_name = 'SYSTEM'
         order by bytes desc)
 where rownum < 10;

prompt <h1>5. archivelog infomation</h1>
prompt <h2>5.21. archive log route information</h2>
archive log list;

prompt <h2>5.2. every day archive size information</h2>
select al.date_time "DATE",
       trunc(sum(al.every_arch_size), 2) || ' MB' "ARCH_SIZE",
       count(1) as "ARCH_AMOUNT"
  from (SELECT distinct ial.SEQUENCE# "sequence",
                        ial.THREAD# "thread",
                        ial.BLOCKS * ial.BLOCK_SIZE / 1024 / 1024 as every_arch_size,
                        to_char(ial.COMPLETION_TIME, 'yyyy-mm-dd') as date_time
          FROM v$archived_log ial
         WHERE ial.COMPLETION_TIME > sysdate - 10) al
 group by al.date_time
 order by "DATE" desc;

prompt <h2>5.3. every hour archive change information</h2>
select to_char(first_time, 'YYYY-MM-DD') "Date",
       to_char(sum(decode(to_char(first_time, 'HH24'), '00', 1, 0)), '9999') "00",
       to_char(sum(decode(to_char(first_time, 'HH24'), '01', 1, 0)), '9999') "01",
       to_char(sum(decode(to_char(first_time, 'HH24'), '02', 1, 0)), '9999') "02",
       to_char(sum(decode(to_char(first_time, 'HH24'), '03', 1, 0)), '9999') "03",
       to_char(sum(decode(to_char(first_time, 'HH24'), '04', 1, 0)), '9999') "04",
       to_char(sum(decode(to_char(first_time, 'HH24'), '05', 1, 0)), '9999') "05",
       to_char(sum(decode(to_char(first_time, 'HH24'), '06', 1, 0)), '9999') "06",
       to_char(sum(decode(to_char(first_time, 'HH24'), '07', 1, 0)), '9999') "07",
       to_char(sum(decode(to_char(first_time, 'HH24'), '08', 1, 0)), '9999') "08",
       to_char(sum(decode(to_char(first_time, 'HH24'), '09', 1, 0)), '9999') "09",
       to_char(sum(decode(to_char(first_time, 'HH24'), '10', 1, 0)), '9999') "10",
       to_char(sum(decode(to_char(first_time, 'HH24'), '11', 1, 0)), '9999') "11",
       to_char(sum(decode(to_char(first_time, 'HH24'), '12', 1, 0)), '9999') "12",
       to_char(sum(decode(to_char(first_time, 'HH24'), '13', 1, 0)), '9999') "13",
       to_char(sum(decode(to_char(first_time, 'HH24'), '14', 1, 0)), '9999') "14",
       to_char(sum(decode(to_char(first_time, 'HH24'), '15', 1, 0)), '9999') "15",
       to_char(sum(decode(to_char(first_time, 'HH24'), '16', 1, 0)), '9999') "16",
       to_char(sum(decode(to_char(first_time, 'HH24'), '17', 1, 0)), '9999') "17",
       to_char(sum(decode(to_char(first_time, 'HH24'), '18', 1, 0)), '9999') "18",
       to_char(sum(decode(to_char(first_time, 'HH24'), '19', 1, 0)), '9999') "19",
       to_char(sum(decode(to_char(first_time, 'HH24'), '20', 1, 0)), '9999') "20",
       to_char(sum(decode(to_char(first_time, 'HH24'), '21', 1, 0)), '9999') "21",
       to_char(sum(decode(to_char(first_time, 'HH24'), '22', 1, 0)), '9999') "22",
       to_char(sum(decode(to_char(first_time, 'HH24'), '23', 1, 0)), '9999') "23",
       count(1) Total
  from v$log_history
 where first_time > sysdate - 30
 group by to_char(first_time, 'YYYY-MM-DD')
 order by "Date";

prompt <h2>5.4. exist earliest archive time</h2>
select min(NAME) name,
       min(to_char(FIRST_TIME, 'yyyy-mm-dd hh24:mi:ss')) time,
       alg.thread#
  from v$archived_log alg
 where alg.DEST_ID in (select arch_dest.DEST_ID
                         from V$ARCHIVE_DEST arch_dest
                        where arch_dest.STATUS = 'VALID')
   and alg.name is not null
   and STANDBY_DEST = 'NO'
   and alg.DELETED = 'NO'
 group by alg.thread#;

prompt <h2>5.5. all exist earliest archive size</h2>
select count(1) "ARCH_AMOUNT",
       trunc(sum(al.blocks * al.block_size) / 1024 / 1024 / 1024, 2) || 'GB' as "EXIST_ARCH_SIZE",
       al.DEST_ID,
       ad.DESTINATION
  from v$archived_log al, V$ARCHIVE_DEST ad
 where al.DEST_ID = ad.DEST_ID
   and ad.STATUS = 'VALID'
   and al.DELETED='NO'
   and al.name is not null
   and al.STANDBY_DEST = 'NO'
 group by al.DEST_ID, ad.DESTINATION;

prompt <h1>6. flashback space information</h1>
prompt <h2>6.1. flashback area size</h2>
select p.NAME,p.VALUE/1024/1024 || ' MB' "size" from v$parameter p where p.NAME='db_recovery_file_dest_size';

prompt <h2>6.2. flashback area route</h2>
select p.NAME,p.VALUE from v$parameter p where p.NAME='db_recovery_file_dest';

prompt <h2>6.3. flashback area information</h2>
select * from V$RECOVERY_AREA_USAGE;

prompt <h1>7. redo infomation</h1>
prompt <h2>7.1. redo size information</h2>
select thread#,group#,members,bytes/1024/1024||'MB' "size",sequence#,status from v$log order by thread#,group#;

prompt <h2>7.2. redo change rate</h2>
select b.recid,
to_char(b.first_time,'yyyy-mm-dd hh24:mi:ss') start_time,
a.recid,
to_char(a.first_time,'yyyy-dd-dd hh24:mi:ss') end_time,
round(((a.first_time-b.first_time)*24)*60,2) minutes
from v$log_history a,v$log_history b
where a.recid=b.recid+1
and a.thread#=b.thread#
     and b.FIRST_TIME>(sysdate-3.04)
order by a.first_time asc;

prompt <h1>8. user and profile information</h1>
prompt <h2>8.1. user information</h2>
select username, profile, expiry_date, account_status from dba_users  where account_status not like 'EXPIRED%LOCKED';

prompt <h2>8.2. profile information</h2>
select dp.profile,dp.resource_name,dp.resource_type,dp.limit,
       rank() OVER(PARTITION BY dp.profile ORDER BY dp.resource_name) AS "GROUP_NUMBER"
  from dba_profiles dp;

prompt <h1>9. sequence information</h1>
select sequence_owner,sequence_name,cycle_flag,order_flag,cache_size from dba_sequences where sequence_owner not like '%SYS%' and ORDER_FLAG='Y' and SEQUENCE_OWNER not in ('DBSNMP','ORDDATA');

prompt <h1>10. ASMDG information</h1>
prompt <h2>10.1. ASMDG space using</h2>
select adg.NAME,adg.TYPE,adg.TOTAL_MB,adg.FREE_MB,adg.OFFLINE_DISKS from V$ASM_DISKGROUP_STAT adg;

prompt <h2>10.2. ASM offline disk</h2>
select ads.NAME "DISK_NAME",adgs.NAME "DG_NAME",ads.STATE,adgs.TYPE,ads.MOUNT_STATUS,
       ads.MODE_STATUS,ads.FAILGROUP,ads.PATH,adgs.OFFLINE_DISKS
  from v$asm_disk_stat ads, v$asm_diskgroup_stat adgs
 where ads.GROUP_NUMBER = adgs.GROUP_NUMBER
   and ads.MODE_STATUS = 'OFFLINE';

prompt <h2>10.3. failgroup information</h2>
select adgs.NAME "DG_NAME",ads.FAILGROUP "FAILGROUP_NAME",adgs.TYPE,
       ads.NAME "DISK_NAME",ads.PATH,
       rank() OVER(PARTITION BY ads.FAILGROUP, adgs.NAME ORDER BY ads.NAME) AS "RN"
  from v$asm_disk_stat ads, v$asm_diskgroup_stat adgs
 where ads.GROUP_NUMBER = adgs.GROUP_NUMBER;

prompt <h1>11. controfile infomation</h1>
select t.NAME,t.STATUS,  to_char(trunc(t.BLOCK_SIZE * t.FILE_SIZE_BLKS / 1024 / 1024, 2), 'FM9999990.0099') || ' MB' "size"  from v$controlfile t;

prompt <h1>12. dababase backup infomation</h1>
prompt <h2>12.1. database backup strategy</h2>
select /*+rule */
 to_char(rbjd.START_TIME, 'yyyy-mm-dd hh24:mi:ss') "BACKUP_START_TIME",
 rbjd.INPUT_TYPE,rbjd.STATUS,
 round(rbjd.ELAPSED_SECONDS / 60,2) "ELAPSED_MIN", rbjd.OUTPUT_DEVICE_TYPE
  from V$RMAN_BACKUP_JOB_DETAILS rbjd
where rbjd.START_TIME > sysdate - 40
 order by "BACKUP_START_TIME" desc;

prompt <h2>12.2. database backup check</h2>
prompt <h3>12.2.1. backup of full or increase database min datafile scn</h3>
select /*+rule */
 to_char(min(bd.CHECKPOINT_TIME), 'yyyy-mm-dd hh24:mi:ss') "BAK_EARLIST_TIME",
 min(bd.CHECKPOINT_CHANGE#) "BAK_DBFILE_MINSCN",
 rs.OBJECT_TYPE
  from V$BACKUP_PIECE bp, V$BACKUP_DATAFILE bd, V$RMAN_STATUS rs
 where bp.SET_STAMP = bd.SET_STAMP
   and bp.SET_COUNT = bd.SET_COUNT
   and bp.RMAN_STATUS_RECID = rs.RECID
   and bp.RMAN_STATUS_STAMP = rs.STAMP
   and bp.DELETED = 'NO'
   and bp.DEVICE_TYPE = 'DISK'
   and rs.OBJECT_TYPE in ('DB INCR', 'DB FULL')
   and bd.FILE# <> 0
 group by rs.OBJECT_TYPE;

prompt <h3>12.2.2. backup of archivelog each thread scn and continuity</h3>
select /*+rule */
 br.THREAD# "THREAD",
 min(br.FIRST_CHANGE#) "BAK_ARCH_MINSEQ_MAXSCN",
 to_char(min(br.FIRST_TIME), 'yyyy-mm-dd hh24:mi:ss') "BAK_EARLIST_TIME",
 max(br.NEXT_CHANGE#) "BAK_ARCH_MAXSCN",
 count(distinct(br.SEQUENCE#)) "REAL_ARCH_BACKUP_TIMES",
 max(br.SEQUENCE# + 1) - min(br.SEQUENCE#) "EXPECT_ARCH_BACKUP_TIMES"
  from V$BACKUP_PIECE bp, V$BACKUP_REDOLOG br
 where bp.SET_STAMP = br.SET_STAMP
   and bp.SET_COUNT = br.SET_COUNT
   and bp.DELETED = 'NO'
   and bp.DEVICE_TYPE = 'DISK'
 group by br.THREAD#;

prompt <h3>12.2.3. not backup archivelog each thread scn and continuity</h3>
select /*+rule */
 al.thread# "THREAD",
 max(br.BAK_ARCH_MAXSCN) "BAK_ARCH_MAXSCN",
 min(al.FIRST_CHANGE#) "NOT_BAK_ARCH_MINSCN",
 max(al.NEXT_CHANGE#) "NOT_BAK_ARCH_MAXSCN",
 count(distinct(al.SEQUENCE#)) "NOT_BAK_ARCH_REAL_NUMBER",
 max(al.SEQUENCE# + 1) - min(al.SEQUENCE#) "NOT_BAK_ARCH_EXPECT_NUMBER"
  from V$archived_log al,
       (select /*+rule */
         ibr.THREAD#,
         max(ibr.SEQUENCE#) "SEQUENCE#",
         max(ibr.NEXT_CHANGE#) "BAK_ARCH_MAXSCN"
          from V$BACKUP_PIECE bp, V$BACKUP_REDOLOG ibr
         where bp.SET_STAMP = ibr.SET_STAMP
           and bp.SET_COUNT = ibr.SET_COUNT
           and bp.DELETED = 'NO'
           and bp.DEVICE_TYPE = 'DISK'
         group by ibr.THREAD#) br
 where al.NAME is not null
   and al.STANDBY_DEST = 'NO'
   and al.THREAD# = br.THREAD#
   and al.SEQUENCE# > br.SEQUENCE#
 group by al.thread#;

prompt <h3>12.2.4. not backup archivelog and redo continuity</h3>
select /*+rule */
 l.thread# "THREAD",
 min(l.FIRST_CHANGE#) "REDO_MINSCN",
 max(al.NEXT_CHANGE#) "NOT_BAK_ARCH_MAXSCN"
  from v$log l,
       (select ial.THREAD#,
               max(ial.SEQUENCE#) "SEQUENCE#",
               max(ial.NEXT_CHANGE#) "NEXT_CHANGE#"
          from v$archived_log ial
         group by ial.THREAD#) al
 where l.THREAD# = al.THREAD#
   and l.SEQUENCE# > al.SEQUENCE#
 group by l.thread#;

prompt <h2>12.3. database can restore earlist time</h2>
select /*+rule */
 to_char(min(rs.END_TIME), 'yyyy-mm-dd hh24:mi:ss'), rs.OBJECT_TYPE
  from V$BACKUP_PIECE bp, V$RMAN_STATUS rs
 where bp.RMAN_STATUS_RECID = rs.RECID
   and bp.RMAN_STATUS_STAMP = rs.STAMP
   and bp.DELETED = 'NO'
   and bp.DEVICE_TYPE = 'DISK'
   and rs.OBJECT_TYPE in ('DB INCR', 'DB FULL')
 group by rs.OBJECT_TYPE;

prompt <h2>12.4. full(increase) database backup times</h2>
select /*+rule */
 bpd.HANDLE,rs.OBJECT_TYPE,to_char(rs.START_TIME, 'yyyy-mm-dd hh24:mi:ss'),
 case
   when bpd.STATUS = 'A' then
    'available'
   when bpd.STATUS = 'D' then
    'deleted'
   else
    'expired'
 end as "STATUS"
  from V$RMAN_STATUS rs
  join v$BACKUP_PIECE_DETAILS bpd
    on rs.STAMP = bpd.RMAN_STATUS_STAMP
   and rs.RECID = bpd.RMAN_STATUS_RECID
 where bpd.STATUS = 'A'
   and rs.OBJECT_TYPE is not null
   and rs.OUTPUT_DEVICE_TYPE = 'DISK'
   and rs.OBJECT_TYPE in ('DB INCR', 'DB FULL');

prompt <h1>13. database blackmail virus</h1>
select trigger_name from all_triggers where trigger_name like 'DBMS_%_INTERNAL% '
union 
select object_name from dba_procedures where object_name like 'DBMS_%_INTERNAL% '
union
select trigger_name from all_triggers where trigger_name like 'DBMS_SUPPORT_DB% '
union
select object_name from dba_procedures where object_name like 'DBMS_SUPPORT_DB% '
union
select trigger_name from all_triggers where trigger_name like 'DBMS_STANDARD_FUN9% '
union
select object_name from dba_procedures where object_name like 'DBMS_STANDARD_FUN9% ';

prompt <h1>14. Statistic info</h1>
select owner,segment_name,segment_type,tablespace_name,bytes/1024/1024 as "Bytes(M)",blocks from dba_segments where segment_name in (select table_name from dba_tables where num_rows=0) and owner not in ('SYS','SYSTEM','SYSMAN','OUTLN','WMSYS','EXFSYS','CTXSYS','DBSNMP','XDB','ORDDATA','ORDSYS','MDSYS','OLAPSYS','APEX_030200');

prompt <h1>15. Database non default parameter</h1>
select name,value,display_value,description from v$parameter where isdefault='FALSE';
spool off
exit

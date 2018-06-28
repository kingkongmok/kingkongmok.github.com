-- conn / as sysdba

set head off

clear break
clear comp
clear col
-- 
SET echo off
SET feedback off
-- SET term off
-- SET pagesize 0
-- SET linesize 200
-- SET newpage 0
-- SET space 0
-- 
-- set pagesize 0
set linesize 9999
set pagesize 100
-- set trimspool on
-- set tab off
-- set echo off
-- set feedback off
set recsep off
set head off
set linesize 9999
set pagesize 100

select count(*) Active_Sessions_count
from v$sqltext_with_newlines t,V$SESSION s
where t.address =s.sql_address
and t.hash_value = s.sql_hash_value
and s.status = 'ACTIVE'
and s.username <> 'SYSTEM'
;
EXIT;

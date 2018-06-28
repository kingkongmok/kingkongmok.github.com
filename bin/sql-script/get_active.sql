-- conn / as sysdba
set linesize 9999
set pagesize 100
column USERNAME format a10;
column 2 format a10;
column OSUSER format a10;
column SQL_ID format a10;
select S.USERNAME, s.sid, s.osuser, t.sql_id, sql_text
from v$sqltext_with_newlines t,V$SESSION s
where t.address =s.sql_address
and t.hash_value = s.sql_hash_value
and s.status = 'ACTIVE'
and s.username <> 'SYSTEM'
order by s.sid,t.piece
;
EXIT;

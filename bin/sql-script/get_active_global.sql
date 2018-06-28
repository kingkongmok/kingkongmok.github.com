-- conn / as sysdba
set linesize 9999
set pagesize 100
select S.USERNAME, s.sid, s.osuser, t.sql_id, sql_text
from gv$sqltext_with_newlines t,gv$SESSION s
where t.address =s.sql_address
and t.hash_value = s.sql_hash_value
and s.status = 'ACTIVE'
and s.username <> 'SYSTEM'
order by s.sid,t.piece
;
EXIT;

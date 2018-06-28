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

-- col 1 format a5
-- col SESSION_ID format a20
-- col TY format a10
-- col LMODE format a20
-- col REQUEST format a20
-- col BLOCK format a20
-- col CTIME format a20

select
count(1)
	from
	gv$locked_object, all_objects, gv$lock
	where
	gv$locked_object.object_id = all_objects.object_id AND
	gv$lock.id1 = all_objects.object_id AND
	gv$lock.sid = gv$locked_object.session_id 
	order by
	session_id, ctime desc, object_name
	;
	EXIT ;

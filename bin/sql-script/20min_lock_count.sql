--conn sys/oracle as sysdba
clear break
clear comp
clear col
set linesize 9999
set pagesize 100
set head off
set echo off
set feedback off
set recsep off

col OBJECT_NAME format a25
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
	gv$lock.sid = gv$locked_object.session_id AND
	gv$lock.ctime > 1200 
	order by
	session_id, ctime desc, object_name
	;
	EXIT ;

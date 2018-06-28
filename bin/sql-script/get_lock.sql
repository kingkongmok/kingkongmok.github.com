-- conn / as sysdba


-- clear break
-- clear comp
-- clear col

-- set pagesize 0
set linesize 9999
set pagesize 100
-- set trimspool on
-- set tab off
-- set echo off
-- set feedback on
set feedback on
-- set recsep off

col OBJECT_NAME format a20
-- col SESSION_ID format a20
-- col TY format a10
-- col LMODE format a20
-- col REQUEST format a20
-- col BLOCK format a20
-- col CTIME format a20

select
object_name, 
	session_id, 
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
	from
	v$locked_object, all_objects, v$lock
	where
	v$locked_object.object_id = all_objects.object_id AND
	v$lock.id1 = all_objects.object_id AND
	v$lock.sid = v$locked_object.session_id
	order by
	session_id, ctime desc, object_name
	;
	EXIT ;

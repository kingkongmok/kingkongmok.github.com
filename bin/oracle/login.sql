set sqlprompt "_USER'@'_CONNECT_IDENTIFIER> "
-- set sqlprompt "[32;47m&_user@&_connect_identifier[30m>[0;49m "
-- set sqlprompt "[33m&_user@&_connect_identifier[30m>[0;49m "
alter session set nls_date_format='yyyy-mm-dd_hh24:mi:ss';     
set linesize 175
set pagesize 45
define _editor=vi

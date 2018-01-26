#! /bin/sh

if [ $# != 2 ]
then
	echo "ZBX_NOTSUPPORTED"
	exit 1;
fi

#. /home/zabbix/etc/oraenv
. /var/lib/zabbix/bin/oraenv

TBSNAME=$1

case $2 in

#'total')
#	sql="select sum(bytes) bytes from dba_data_files where tablespace_name='$TBSNAME';"
#	;;
#
#'free')
#	sql="select sum(bytes) bytes from dba_free_space where tablespace_name='$TBSNAME';"
#	;;
#
#'pused')
#	sql="col pct format 999;
#             select (a.bytes-b.bytes)/a.bytes*100 as pct
#             from (select sum(bytes) bytes from dba_data_files where tablespace_name='$TBSNAME') a,
#                  (select sum(bytes) bytes from dba_free_space where tablespace_name='$TBSNAME') b;"
#	;;
#
#'pfree')
#	sql="col pct format 999;
#             select b.bytes/a.bytes*100 as pct
#             from (select sum(bytes) bytes from dba_data_files where tablespace_name='$TBSNAME') a,
#                  (select sum(bytes) bytes from dba_free_space where tablespace_name='$TBSNAME') b;"
#	;;

'total')
	sql="select TABLESPACE_SIZE from DBA_TABLESPACE_USAGE_METRICS 
		where TABLESPACE_NAME='$TBSNAME';"
	;;

'free')
	sql="select ( TABLESPACE_SIZE - USED_SPACE ) from DBA_TABLESPACE_USAGE_METRICS 
		where TABLESPACE_NAME='$TBSNAME';"
	;;

'pfree')
	sql="select round(100-USED_PERCENT,0) from DBA_TABLESPACE_USAGE_METRICS 
		where TABLESPACE_NAME='$TBSNAME';"
	;;

*)
        echo "ZBX_NOTSUPPORTED"
        rval=1
        exit $rval
        ;;
esac


if [ a"$sql" != a"" ]; then
#       echo "$sql"
       #echo "$sql" | sqlplus -s /nolog @/var/lib/zabbix/bin/cont.sql
       result=`echo "$sql" | sqlplus -s /nolog @/var/lib/zabbix/bin/cont.sql`
       echo $result

fi
rval=$?

if [ "$rval" -ne 0 ]; then
  echo "ZBX_NOTSUPPORTED"
fi

exit $rval

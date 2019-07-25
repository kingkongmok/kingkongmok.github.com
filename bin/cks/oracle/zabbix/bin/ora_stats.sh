#! /bin/sh

if [ $# != 1 ]
then
	echo "ZBX_NOTSUPPORTED"
	exit 1;
fi

. /var/lib/zabbix/bin/oraenv


case $1 in

'active')
	sql="Select count(1) From V\$session where status='ACTIVE' and username <> 'ZABBIX';"
	;;

'lock')
	sql="select count(1) from V\$locked_object;"
	;;

'process')
	sql="select count(*) from v\$process;"
	;;
'tmptbs')
        sql="select round(100*(free_space / Tablespace_size) ,0) perc  from dba_temp_free_space;"
        ;;


*)
        echo "ZBX_NOTSUPPORTED"
        rval=1
        exit $rval
        ;;
esac


if [ a"$sql" != a"" ]; then
	result=`echo "$sql" | sqlplus -s /nolog @/var/lib/zabbix/bin/cont.sql`
	echo $result
fi
rval=$?

if [ "$rval" -ne 0 ]; then
  echo "ZBX_NOTSUPPORTED"
fi

exit $rval

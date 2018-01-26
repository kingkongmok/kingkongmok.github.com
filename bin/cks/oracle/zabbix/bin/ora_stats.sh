#! /bin/sh

if [ $# != 1 ]
then
	echo "ZBX_NOTSUPPORTED"
	exit 1;
fi

#. /home/zabbix/etc/oraenv
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

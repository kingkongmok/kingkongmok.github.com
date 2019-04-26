#! /bin/sh

if [ $# != 1 ]
then
	echo "ZBX_NOTSUPPORTED"
	exit 1;
fi

. /var/lib/zabbix/bin/oraenv


case $1 in

'count')
	sql="select count(1) from v\$archive_dest where error is not null;"
	;;

'info')
	sql="select error from v\$archive_dest where error is not null;"
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

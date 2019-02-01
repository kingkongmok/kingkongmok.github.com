#! /bin/sh

if [ $# != 1 ]
then
	echo "ZBX_NOTSUPPORTED"
	exit 1;
fi

. /var/lib/zabbix/bin/oraenv


case $1 in

'finishlag')
        # 获取lag的时间
	sql="select value from  V\$DATAGUARD_STATS where name='apply finish time';"
	;;

*)
        echo "ZBX_NOTSUPPORTED"
        rval=1
        exit $rval
        ;;
esac


if [ a"$sql" != a"" ]; then
	result=`echo "$sql" | sqlplus -s /nolog @/var/lib/zabbix/bin/cont.sql`
        # 转换时间为秒 +00 00:01:14.678 更换为 74
	echo $result | perl -nae '@a=split/:/,$F[1]; print $a[0]*60*60 + $a[1]*60 + int($a[2]). "\n"'
fi
rval=$?

if [ "$rval" -ne 0 ]; then
  echo "ZBX_NOTSUPPORTED"
fi

exit $rval

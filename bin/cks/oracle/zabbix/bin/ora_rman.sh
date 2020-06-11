#! /bin/sh

if [ $# != 1 ]
then
        echo "ZBX_NOTSUPPORTED"
        exit 1;
fi

. /var/lib/zabbix/bin/oraenv


case $1 in

'status')
        sql="select status from ( select status from v\$rman_backup_job_details order by SESSION_KEY desc ) where rownum=1 ;"
        ;;

'day')
        sql="select day from ( select round(sysdate - START_TIME, 0) day from v\$rman_backup_job_details order by SESSION_KEY desc ) where rownum=1 ;"
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

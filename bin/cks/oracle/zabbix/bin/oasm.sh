#! /bin/sh

if [ $# != 2 ]
then
        echo "ZBX_NOTSUPPORTED"
        exit 1;
fi

. /var/lib/zabbix/bin/oraenv

ASMNAME=$1

case $2 in

'total')
        sql="select TOTAL_MB from v\$asm_diskgroup where NAME='$ASMNAME';"
        ;;

'free')
        sql="select FREE_MB from v\$asm_diskgroup where NAME='$ASMNAME';"
        ;;

'pfree')
        sql="select round(100*FREE_MB/TOTAL_MB,0) from v\$asm_diskgroup where NAME='$ASMNAME';"
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

#! /bin/sh

. /var/lib/zabbix/bin/oraenv

sql="select distinct NAME from v\$asm_diskgroup;"

echo "{"
echo "\"data\":["

echo "$sql" | sqlplus -s /nolog @/var/lib/zabbix/bin/cont.sql |  perl -pe 's/.*/{\"{#ASMNAME}\":\"$&\"}/; s/$/,/ unless eof()' 


echo "]"
echo "}"


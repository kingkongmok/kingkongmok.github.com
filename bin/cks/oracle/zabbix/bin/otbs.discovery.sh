#! /bin/sh

. /var/lib/zabbix/bin/oraenv

sql="select TABLESPACE_NAME from DBA_TABLESPACE_USAGE_METRICS;"

echo -n "{"
echo -n "\"data\":["

echo "$sql" | sqlplus -s /nolog @/var/lib/zabbix/bin/cont.sql |  perl -pe 's/.*/{\"{#TBSNAME}\":\"$&\"}/; s/$/,/ unless eof()' 

echo -n "]"
echo -n "}"



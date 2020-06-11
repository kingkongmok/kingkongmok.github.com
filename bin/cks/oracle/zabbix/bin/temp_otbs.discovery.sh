#! /bin/sh

#. /home/zabbix/etc/oraenv
. /var/lib/zabbix/bin/oraenv

sql="SELECT TABLESPACE_NAME FROM DBA_TEMP_FREE_SPACE;"

echo -n "{"
echo -n "\"data\":["

echo "$sql" | sqlplus -s /nolog @/var/lib/zabbix/bin/cont.sql |  perl -pe 's/.*/{\"{#TEMPTBSNAME}\":\"$&\"}/; s/$/,/ unless eof()' 


echo -n "]"
echo -n "}"



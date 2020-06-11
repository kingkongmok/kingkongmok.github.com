#! /bin/sh

. /var/lib/zabbix/bin/oraenv

#sql="select distinct tablespace_name from dba_data_files;"
sql="select distinct NAME from v\$asm_diskgroup;"

echo "{"
echo "\"data\":["

echo "$sql" | sqlplus -s /nolog @/var/lib/zabbix/bin/cont.sql |  perl -pe 's/.*/{\"{#ASMNAME}\":\"$&\"}/; s/$/,/ unless eof()' 
#result=`echo "$sql" | sqlplus -s /nolog @/var/lib/zabbix/bin/cont.sql `
#echo "$result" | perl -pe 's/.*/{\"{#ASMNAME}\":\"$&\"}/; s/$/,/ unless eof()'


echo "]"
echo "}"

